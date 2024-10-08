import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

/// toggle!
void _toggle() => ApiToggle.toggle.toggle();

class DemoButton extends StatelessWidget {
  const DemoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Route.of(context) == Route.mapping ? const Mapping() : const PressToStretch();
  }
}

class Mapping extends StatelessWidget {
  const Mapping({super.key});

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
      onPressed: _toggle,
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
      child: const RepaintBoundary(child: SizedBox(height: 100, child: Center(child: button))),
    );
  }
}

class AnimatedStretch extends AnimatedValue<double> {
  const AnimatedStretch({
    super.key,
    required double stretch,
    required super.duration,
    super.curve,
    super.onEnd,
    super.child,
  }) : super(value: stretch, lerp: lerpDouble);

  static Matrix4 _stretch(double value) {
    return Matrix4.diagonal3Values(value, 1 / value, 1.0);
  }

  @override
  Widget build(BuildContext context, Animation<double> animation) {
    return MatrixTransition(animation: animation, onTransform: _stretch, child: child);
  }
}

extension type const PressToStretch._(RepaintBoundary _) implements RepaintBoundary {
  const PressToStretch()
      : _ = const RepaintBoundary(
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              child: _PressToStretch(),
            ),
          ),
        );
}

class _PressToStretch extends StatefulWidget {
  const _PressToStretch();

  @override
  State<_PressToStretch> createState() => _PressToStretchState();
}

class _PressToStretchState extends State<_PressToStretch> {
  double stretch = 1.0;
  Duration duration = Duration.zero;
  Curve curve = Curves.linear;
  VoidCallback? onEnd;
  bool waiting = false;
  void stopWaiting() {
    setState(() => waiting = false);
    _toggle();
  }

  void tension([_]) {
    setState(() {
      stretch = 3;
      duration = const Seconds(3);
      curve = Curves.easeOutQuart;
      onEnd = null;
    });
  }

  void release([_]) {
    setState(() {
      waiting = true;
      stretch = 1;
      duration = const Seconds(0.5);
      curve = Curves.bounceOut;
      onEnd = stopWaiting;
    });
  }

  @override
  Widget build(BuildContext context) {
    const stack = Stack(
      children: [
        Streeeetch(),
        Positioned.fill(
          child: FractionallySizedBox.scaled(
            scale: 3 / 4,
            alignment: Alignment(0, 1 / 3),
            child: FittedBox(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'press & hold to\n'),
                  TextSpan(
                    text: 'stretch!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 44,
                    ),
                  ),
                ]),
                style: TextStyle(
                  fontFamily: 'gaegu',
                  height: 1,
                  overflow: TextOverflow.visible,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onPanDown: waiting ? null : tension,
      onPanEnd: waiting ? null : release,
      child: MouseRegion(
        cursor: waiting ? MouseCursor.defer : SystemMouseCursors.click,
        child: AnimatedStretch(
          stretch: stretch,
          duration: duration,
          curve: curve,
          onEnd: onEnd,
          child: stack,
        ),
      ),
    );
  }
}

class Streeeetch extends LeafRenderObjectWidget {
  const Streeeetch({super.key});

  @override
  RenderBox createRenderObject(BuildContext context) => _Streeeetch();
}

class _Streeeetch extends RenderBox with BiggestBox {
  static final yellowFill = Paint()..color = const Color(0xfff0ff30);

  @override
  void paint(PaintingContext context, Offset offset) {
    final Size(width: w, height: h) = size;

    final r = h / 4;
    final radius = Radius.circular(r);
    final squeeze = r / 4;
    final firmness = h / 2;

    final path = Path()
      ..moveTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: radius)
      ..cubicTo(firmness, 0, firmness, squeeze, w / 2, squeeze)
      ..cubicTo(w - firmness, squeeze, w - firmness, 0, w - r, 0)
      ..arcToPoint(Offset(w, r), radius: radius)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: radius)
      ..cubicTo(w - firmness, h, w - firmness, h - squeeze, w / 2, h - squeeze)
      ..cubicTo(firmness, h - squeeze, firmness, h, r, h)
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: radius)
      ..lineTo(0, r)
      ..close();

    context.canvas.drawPath(path.shift(offset), yellowFill);
  }
}
