import 'dart:collection';

import 'package:nate_thegrate/the_good_stuff.dart';

enum Character {
  letter,
  number,
  dot,
  plain,
  quote;

  factory Character.from(int code) => switch (code) {
        39 => quote,
        46 => dot,
        >= 48 && <= 57 => number,
        >= 64 && <= 122 => letter,
        _ => plain,
      };

  static List<(Character, String)> split(String input) {
    final result = <(Character, String)>[];
    final buffer = StringBuffer();
    Character? current = plain;
    void addChar(Character type, int code) {
      if (type != current) {
        result.add((current ?? quote, '$buffer'));
        buffer.clear();
        current = type;
      }
      buffer.writeCharCode(code);
    }

    for (int i = 0; i < input.length; i++) {
      final int code = input.codeUnitAt(i);

      switch ((current, Character.from(code))) {
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
      for (final (type, snippet) in Character.split(text))
        TextSpan(
          text: snippet,
          style: TextStyle(
              color: switch (type) {
            Character.plain => _plain,
            Character.quote => _string,
            Character.number => _number,
            Character.letter => _wordColor(snippet),
            Character.dot => throw Error(),
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
      'double' || 'dynamic' || '_AnimatedStretchState' => _class,
      'class' || 'extends' || 'super' || 'this' => _blueKeyword,
      'final' || 'const' || 'required' || 'as' || 'void' => _blueKeyword,
      'return' || 'if' => _purpleKeyword,
      'forEachTween' || 'createState' || 'build' || '_toggle' => _function,
      'evaluate' || 'resolveWith' || 'contains' => _function,
      'pressed' || 'hovered' => _enum,
      _ => _variable,
    };
  }

  static const _mapping = '''\
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
  onPressed: _toggle,
  child: Text('pretty cool button!'),
);
''';

  static const _resolveWith = '''\
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
  onPressed: _toggle,
  child: const Text('pretty cool button!'),
);
''';

  static const _animatedValue = '''\
class AnimatedStretch extends AnimatedValue<double> {
  const AnimatedStretch({
    super.key,
    required double stretch,
    required super.duration,
    super.curve,
    super.onEnd,
    super.child,
  }) : super(value: stretch, lerp: lerpDouble);

  @override
  Widget build(BuildContext context, double value) {
    return Transform.scale(scaleX: value, scaleY: 1 / value, child: child);
  }
}
''';
  static const _implicitlyAnimatedWidget = '''\
class AnimatedStretch extends ImplicitlyAnimatedWidget {
  const AnimatedStretch({
    super.key,
    required this.stretch,
    required super.duration,
    super.curve,
    super.onEnd,
    this.child,
  });

  final double stretch;
  final Widget? child;

  @override
  AnimatedWidgetBaseState<AnimatedStretch> createState() => _AnimatedStretchState();
}

class _AnimatedStretchState extends AnimatedWidgetBaseState<AnimatedStretch> {
  Tween<double>? stretch;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    stretch = visitor(
      stretch,
      widget.stretch,
      (dynamic value) => Tween<double>(begin: value),
    )! as Tween<double>;
  }

  @override
  Widget build(BuildContext context) {
    final stretch = this.stretch!.evaluate(animation);
    return Transform.scale(scaleX: stretch, scaleY: 1 / stretch, child: widget.child);
  }
}
''';
  static final _cache = HashMap<String, VsCode>();
  static const defaultStyle = TextStyle(
    inherit: false,
    fontFamily: 'roboto mono',
    color: _plain,
    overflow: TextOverflow.clip,
  );
  static Text of(BuildContext context) {
    final text = switch ((Route.of(context), ApiToggle.of(context))) {
      (Route.mapping, true) => _mapping,
      (Route.mapping, false) => _resolveWith,
      (Route.animation, true) => _animatedValue,
      (Route.animation, false) => _implicitlyAnimatedWidget,
      _ => throw Error(),
    };

    return Text.rich(
      VsCode._fromText(text),
      style: defaultStyle,
      softWrap: false,
      textAlign: TextAlign.left,
    );
  }
}
