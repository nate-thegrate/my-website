/// A dart script that updates the `pr_data.g.dart` file.
///
/// Can be run manually or via GitHub actions.
library;

import 'dart:io';

import 'package:graphql/client.dart';

import 'token.dart';

void main() async {
  final String prList = await query('update_pull_requests/pr_query.gql');
  final String text = """\
part of 'pr_data.dart';

const flutterPRs = <PullRequest>[$prList];
""";

  File('lib/stats/pr_data.g.dart').writeAsString(text);
}

Future<String> query(String filepath) async {
  final client = GraphQLClient(
    cache: GraphQLCache(),
    link: HttpLink(
      'https://api.github.com/graphql',
      defaultHeaders: {'Authorization': 'Bearer $token'},
    ),
  );
  final queryOptions = QueryOptions<String>(
    document: gql(File(filepath).readAsStringSync()),
    parserFn: parse,
  );

  return (await client.query(queryOptions)).parsedData!;
}

String parse(Map<String, dynamic> data) {
  final buffer = StringBuffer()..writeln();

  final {'user': {'pullRequests': {'nodes': nodes as List}}} = data;
  for (final pr in nodes) {
    final {
      'title': title as String,
      'url': url as String,
      'additions': additions as int,
      'deletions': deletions as int,
      'labels': {'nodes': labels as List},
    } = pr;

    final bool refactor = labels.any((label) => label['name'] == 'refactor');

    final parsed = """\
  PullRequest(
    title: '''$title''',
    url: '''$url''',
    diffs: ($additions, -$deletions),
    refactor: $refactor,
  ),
""";

    buffer.writeln(parsed.trimRight());
  }

  return buffer.toString();
}
