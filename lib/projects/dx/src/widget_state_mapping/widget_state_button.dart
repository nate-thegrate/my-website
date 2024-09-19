import 'dart:collection';

import 'package:nate_thegrate/the_good_stuff.dart';

class WidgetStateButton extends StatelessWidget {
  const WidgetStateButton() : super(key: _key);
  static const _key = GlobalObjectKey(WidgetStateButton);

  static void _switch() {
    _key.currentContext!.read<ToggleMapping>().toggle();
  }

  @override
  Widget build(BuildContext context) {
    const clear = Color(0x01000000);
    const black = Color(0xff000000);
    const pink = Color(0xfffff0f8);
    const pink2 = Color(0x40ff0080);
    const spring = Color(0xff40ffa0);
    const spring2 = Color(0xff60ffb0);
    const spring3 = Color(0x4000ff80);

    final elevation = WidgetStateMapper({
      WidgetState.hovered & ~WidgetState.pressed: 3.0,
      WidgetState.any: 0.0,
    });

    const button = FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateMapper({
          WidgetState.pressed: black,
          WidgetState.hovered: spring2,
          WidgetState.any: spring,
        }),
        foregroundColor: WidgetStateMapper({
          WidgetState.pressed: pink,
          WidgetState.any: black,
        }),
        overlayColor: WidgetStateMapper({
          WidgetState.pressed: pink2,
          WidgetState.hovered: clear,
          WidgetState.any: spring3,
        }),
      ),
      onPressed: _switch,
      child: Text('pretty cool button!'),
    );

    return Theme(
      data: ThemeData(
        splashFactory: InkSparkle.splashFactory,
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            elevation: elevation,
            shadowColor: const WidgetStatePropertyAll(spring2),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            ),
          ),
        ),
      ),
      child: const SizedBox(height: 100, child: Center(child: button)),
    );
  }
}

enum _CharType {
  letter,
  number,
  dot,
  plain,
  quote;

  factory _CharType.from(int code) => switch (code) {
        39 => quote,
        46 => dot,
        >= 48 && <= 57 => number,
        >= 65 && <= 122 => letter,
        _ => plain,
      };

  static List<(_CharType, String)> split(String input) {
    final result = <(_CharType, String)>[];
    final buffer = StringBuffer();
    _CharType? current = plain;
    void addChar(_CharType type, int code) {
      if (type != current) {
        result.add((current ?? quote, '$buffer'));
        buffer.clear();
        current = type;
      }
      buffer.writeCharCode(code);
    }

    for (int i = 0; i < input.length; i++) {
      final int code = input.codeUnitAt(i);

      switch ((current, _CharType.from(code))) {
        case (_, quote):
          final previous = current;
          addChar(quote, code);
          if (previous == quote) {
            current = null;
          }
        case (quote, _):
          addChar(quote, code);

        case (!= letter, number):
        case (number, dot || letter):
          addChar(number, code);

        case (_, letter):
        case (letter, number):
          addChar(letter, code);

        default:
          addChar(plain, code);
      }
    }
    result.add((current ?? quote, '$buffer'));
    return result;
  }
}

/// Syntax highlighting!
extension type VsCode._(TextSpan _textSpan) implements TextSpan {
  factory VsCode._fromText(String text) {
    final children = <TextSpan>[
      for (final (type, snippet) in _CharType.split(text))
        TextSpan(
          text: snippet,
          style: TextStyle(
              color: switch (type) {
            _CharType.plain => _plain,
            _CharType.quote => _string,
            _CharType.number => _number,
            _CharType.letter => _wordColor(snippet),
            _CharType.dot => throw Error(),
          }),
        ),
    ];

    return _cache[text] ??= VsCode._(TextSpan(children: children));
  }

  static const _plain = Color(0xffcccccc);
  static const _class = Color(0xff4ec9b0);
  static const _enum = Color(0xff4fc1ff);
  static const _number = Color(0xffb5cea8);
  static const _string = Color(0xffce9178);
  static const _function = Color(0xffdcdcaa);
  static const _variable = Color(0xff9cdcfe);
  static const _blueKeyword = Color(0xff569cd6);
  static const _purpleKeyword = Color(0xffc586c0);

  static Color _wordColor(String word) {
    final start = word[0];
    if (start != start.toLowerCase()) {
      return _class;
    }
    return switch (word) {
      'final' || 'const' => _blueKeyword,
      'return' || 'if' => _purpleKeyword,
      'resolveWith' || 'build' || '_switch' || 'contains' => _function,
      'pressed' || 'hovered' => _enum,
      _ => _variable,
    };
  }

  static const _concise = '''\
final elevation = WidgetStateMapper({
  WidgetState.hovered & ~WidgetState.pressed: 3.0,
  WidgetState.any: 0.0,
});

const button = FilledButton(
  style: ButtonStyle(
    backgroundColor: WidgetStateMapper({
      WidgetState.pressed: black,
      WidgetState.hovered: spring2,
      WidgetState.any:     spring,
    }),
    foregroundColor: WidgetStateMapper({
      WidgetState.pressed: pink,
      WidgetState.any:     black,
    }),
    overlayColor: WidgetStateMapper({
      WidgetState.pressed: pink2,
      WidgetState.hovered: clear,
      WidgetState.any:     spring3,
    }),
  ),
  onPressed: _switch,
  child: Text('pretty cool button!'),
);
''';

  static const _verbose = '''\
final elevation = WidgetStateProperty.resolveWith((states) {
  return states.contains(WidgetState.hovered)
     && !states.contains(WidgetState.pressed)
      ? 3.0
      : 0.0;
});

final button = FilledButton(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return black;
      }
      if (states.contains(WidgetState.hovered)) {
        return spring2;
      }
      return spring;
    }),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.pressed) ? pink : black,
    ),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return pink2;
      }
      if (states.contains(WidgetState.hovered)) {
        return clear;
      }
      return spring3;
    }),
  ),
  onPressed: _switch,
  child: const Text('pretty cool button!'),
);
''';
  static final _cache = HashMap<String, VsCode>();

  static Text of(BuildContext context) {
    const defaultStyle = TextStyle(
      inherit: false,
      fontFamily: 'roboto mono',
      color: _plain,
      overflow: TextOverflow.clip,
    );
    final text = ToggleMapping.of(context) ? _concise : _verbose;

    return Text.rich(VsCode._fromText(text), style: defaultStyle, softWrap: false);
  }
}

class CodeCaption extends StatelessWidget {
  const CodeCaption({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      ToggleMapping.of(context) ? 'WidgetState mapping' : 'Widget property resolver',
      textAlign: TextAlign.center,
      style: const TextStyle(
        inherit: false,
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 3,
        leadingDistribution: TextLeadingDistribution.even,
      ),
    );
  }
}

class CodeSample extends StatelessWidget {
  const CodeSample({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
        child: SizedBox(width: 600, height: 625, child: VsCode.of(context)),
      ),
    );
  }
}
