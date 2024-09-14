import 'package:nate_thegrate/the_good_stuff.dart';

extension type TickedOff._(TextSpan _span) implements TextSpan {
  TickedOff(String input)
      : _span = _cache[input] ??= TextSpan(children: [
          for (final (index, snippet) in input.split('`').indexed)
            if (index.isEven)
              TextSpan(text: snippet)
            else
              WidgetSpan(child: _CodeSnippet(snippet)),
        ]);

  static final _cache = <String, TextSpan>{};
}

class _CodeSnippet extends StatelessWidget {
  const _CodeSnippet(this.snippet);

  final String snippet;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = Focus.of(context).hasFocus
        ? (const Color(0xffe4ffff), PullRequest.color)
        : (const Color(0xfffaffff), null);

    return Transform.translate(
      offset: const Offset(0, 0.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: ColoredBox(
          color: background,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              snippet,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'roboto mono',
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
