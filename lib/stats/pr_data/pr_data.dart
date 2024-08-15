import 'package:nate_thegrate/the_good_stuff.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'pr_data.g.dart';

final List<PullRequest> refactorPRs = flutterPRs.where((pr) => pr.refactor).toList();

enum PRLayout {
  compact,
  spaced;

  factory PRLayout._compute(BuildContext context, PRLayout? _) {
    return MediaQuery.sizeOf(context).width < 500 ? compact : spaced;
  }

  factory PRLayout.of(BuildContext context) => Provider.of<PRLayout>(context);
}

class PRLayoutProvider extends ProxyProvider0<PRLayout> {
  PRLayoutProvider({super.key, required Widget super.child}) : super(update: PRLayout._compute);
}

class PullRequest extends StatefulWidget {
  const PullRequest({
    super.key,
    required this.title,
    required this.url,
    required this.diffs,
    required this.refactor,
  });

  factory PullRequest.total({required bool onlyRefactor}) {
    if (onlyRefactor ? _refactoring : _overall case final cached?) {
      return cached;
    }

    final pulls = onlyRefactor ? refactorPRs : flutterPRs;

    int additions = 0, deletions = 0;
    for (final PullRequest(:diffs) in pulls) {
      additions += diffs.$1;
      deletions += diffs.$2;
    }

    String url = 'https://github.com/flutter/flutter/pulls?q=author%3Anate-thegrate+is%3Amerged';
    if (onlyRefactor) url += '+label%3Arefactor';

    final pr = PullRequest(
      title: 'Total',
      url: url,
      diffs: (additions, deletions),
      refactor: onlyRefactor,
    );

    return onlyRefactor ? _refactoring = pr : _overall = pr;
  }

  static PullRequest? _overall, _refactoring;

  final String title;
  final String url;
  final (int, int) diffs;
  final bool refactor;

  static const color = Color(0xff00a0a0);
  static const borderColor = Color(0xffd0e0e0);
  static const border = BorderSide(color: borderColor);

  @override
  State<PullRequest> createState() => _PullRequestState();
}

class _PullRequestState extends State<PullRequest> {
  late final bool isTotal = widget.title == 'Total';
  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(builder: (context) {
        final focusNode = Focus.of(context);
        final focused = focusNode.hasFocus;
        void focus(_) {
          if (!focusNode.hasFocus) focusNode.requestFocus();
        }

        const border = Border.symmetric(
          vertical: BorderSide(color: Colors.transparent),
          horizontal: PullRequest.border,
        );

        final diffs = Diffs(
          widget.diffs,
          key: GlobalObjectKey((widget.diffs, widget.url)),
        );
        final contents = Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: focused ? PullRequest.color : null,
                      fontWeight: isTotal ? FontWeight.w600 : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (focused) diffs else ColoredBox(color: Colors.white54, child: diffs),
            ],
          ),
        );

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: focus,
          onHover: focus,
          onExit: (_) => Future.microtask(focusNode.unfocus),
          child: GestureDetector(
            onTap: () => launchUrlString(widget.url),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: focused ? Colors.white70 : Colors.transparent,
                border: border,
              ),
              child: contents,
            ),
          ),
        );
      }),
    );
  }
}

class Diffs extends StatelessWidget {
  const Diffs(this.diffs, {super.key});

  final (int, int) diffs;

  static const green = Color(0xff007060);
  static const red = Color(0xffc00060);

  @override
  Widget build(BuildContext context) {
    final (additions, deletions) = diffs;
    final delta = additions - deletions;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Center(
              child: Text(
                '+$additions',
                style: const TextStyle(color: green),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Center(
              child: Text(
                '-$deletions',
                style: const TextStyle(color: red),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Center(
              child: Text(
                '$delta',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
