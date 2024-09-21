import 'package:nate_thegrate/stats/ticked_off.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

part 'pr_data.g.dart';

final List<PullRequest> refactorPRs = flutterPRs.where((pr) => pr.refactor).toList();

class PullRequest extends StatelessWidget {
  const PullRequest({
    super.key,
    required this.title,
    required this.url,
    required this.date,
    required this.diffs,
    required this.refactor,
  }) : _isTotal = title == 'Total';

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

    String url =
        'https://github.com/pulls?q=author%3Anate-thegrate+is%3Amerged+label%3Aautosubmit';
    if (onlyRefactor) url += '+label%3Arefactor';

    final pr = PullRequest(
      title: 'Total',
      url: url,
      date: ' since 2023',
      diffs: (additions, deletions),
      refactor: onlyRefactor,
    );

    return onlyRefactor ? _refactoring = pr : _overall = pr;
  }

  static PullRequest? _overall, _refactoring;

  final String title;
  final bool _isTotal;
  final String url;
  final String date;
  final (int, int) diffs;
  final bool refactor;

  static const color = Color(0xff00a0a0);
  static const borderColor = Color(0xffd0e0e0);
  static const border = BorderSide(color: borderColor);

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

        late final prCount = (refactor ? refactorPRs : flutterPRs).length;

        final textStyle = TextStyle(color: focused ? PullRequest.color : null);
        final Text text;
        if (_isTotal) {
          text = Text('$prCount contributions', style: textStyle);
        } else {
          text = Text.rich(
            TickedOff(title),
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        final rightColumn = RightColumn(
          diffs,
          date,
          key: GlobalObjectKey((diffs, url)),
        );
        final contents = Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              const SizedBox(width: 8),
              if (_isTotal)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    title,
                    style: textStyle.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Expanded(
                child: Align(alignment: Alignment.centerLeft, child: text),
              ),
              if (focused) rightColumn else ColoredBox(color: Colors.white54, child: rightColumn),
            ],
          ),
        );

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: focus,
          onHover: focus,
          onExit: (_) => Future.microtask(focusNode.unfocus),
          child: GestureDetector(
            onTap: () => launchUrlString(url),
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

class RightColumn extends StatelessWidget {
  const RightColumn(this.diffs, this.date, {super.key});

  final (int, int) diffs;
  final String date;

  static const green = Color(0xff007060);
  static const red = Color(0xffc00060);

  static const dateWidth = 115.0;
  static const diffWidth = 150.0;

  @override
  Widget build(BuildContext context) {
    if (Refactoring.of(context)) {
      final (additions, deletions) = diffs;
      final delta = additions - deletions;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(children: [
          Diffs('+$additions', style: const TextStyle(color: green)),
          Diffs('-$deletions', style: const TextStyle(color: red)),
          Diffs('$delta', style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      );
    }

    return SizedBox(
      width: dateWidth,
      height: double.infinity,
      child: DefaultTextStyle(
        style: TextStyle(
          color: Focus.of(context).hasFocus ? Colors.black87 : const Color(0xff606060),
          fontSize: 14,
          fontFamily: 'roboto mono',
          fontVariations: const [FontVariation.weight(650)],
        ),
        child: Center(child: Text(date)),
      ),
    );
  }
}

class Diffs extends Text {
  const Diffs(super.data, {super.key, super.style});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: RightColumn.diffWidth / 3,
      child: Center(child: super.build(context)),
    );
  }
}
