/// A dart script that updates the `pr_data.g.dart` file.
///
/// Can be run manually or via GitHub actions.
library;

import 'dart:io';

import 'package:graphql/client.dart';

import 'token.dart';

Future<QueryResult<StringBuffer>> query(String filepath) {
  final client = GraphQLClient(
    cache: GraphQLCache(),
    link: HttpLink(
      'https://api.github.com/graphql',
      defaultHeaders: {'Authorization': 'Bearer $token'},
    ),
  );
  return client.query(
    QueryOptions<StringBuffer>(
      document: gql(File(filepath).readAsStringSync()),
      parserFn: parseQuery,
    ),
  );
}

StringBuffer parseQuery(Map<String, dynamic> data) {
  final {'user': {'pullRequests': {'nodes': nodes as List<dynamic>}}} = data;
  final prs = StringBuffer()..writeln();

  for (final pr in nodes) {
    final {
      'title': title as String,
      'url': url as String,
      'additions': additions as int,
      'deletions': deletions as int,
      'labels': {'nodes': labels as List<dynamic>},
    } = pr! as Map;

    final bool refactor = labels.any((label) => label['name'] == 'refactor');

    final parsed = """\
  PullRequest(
    title: '''$title''',
    url: '''$url''',
    diffs: ($additions, -$deletions),
    refactor: $refactor,
  ),
""";

    prs.writeln(parsed.trimRight());
  }

  return prs;
}

void main() async {
  final prs = (await query('update_pull_requests/pr_query.gql')).parsedData;

  File('lib/stats/pr_data.g.dart').writeAsString(
    """\
part of 'pr_data.dart';

const flutterPRs = <PullRequest>[$prs];
""",
  );
}
