part 'pr_data.g.dart';

class PullRequest {
  const PullRequest({
    required this.title,
    required this.url,
    required this.diffs,
    required this.refactor,
  });

  final String title;
  final String url;
  final (int, int) diffs;
  final bool refactor;
}
