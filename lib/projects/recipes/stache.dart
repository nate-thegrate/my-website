import 'dart:math';

import 'package:nate_thegrate/the_good_stuff.dart';

class JiggleStache extends ToggleAnimation {
  JiggleStache({required super.vsync}) : super(duration: const Seconds(0.18));

  double _evaluate(double Function(double) transform) {
    return isForwardOrCompleted ? transform(value) : 1 - transform(1 - value);
  }

  static double _topTransform(double t) => Curves.ease.transform(min(t * 2, 1));
  static double _bottomTransform(double t) => t * t * t * (16 * t * t - 35 * t + 20);

  double get top => _evaluate(_topTransform);
  double get bottom => _evaluate(_bottomTransform);
}

class StacheStash extends LeafRenderObjectWidget {
  const StacheStash({super.key});

  @override
  Stache createRenderObject(BuildContext context) {
    final jiggle = JiggleStache(vsync: Navigator.of(context));
    final states = context.read<WidgetStates?>();

    return Stache(jiggle, states);
  }
}

class Stache extends RenderBox {
  Stache(this.jiggle, this.states) {
    jiggle.addListener(markNeedsPaint);
    states?.addListener(_updateAnimation);
  }

  @override
  void dispose() {
    jiggle.removeListener(markNeedsPaint);
    states?.removeListener(_updateAnimation);
    super.dispose();
  }

  void _loopBack() {
    if (jiggle.value > 0.75) {
      jiggle
        ..removeListener(_loopBack)
        ..animateTo(0);
    }
  }

  void _updateAnimation() {
    final isPressed = states!.contains(WidgetState.pressed);
    if (isPressed != jiggle.isForwardOrCompleted) {
      if (isPressed) {
        jiggle.animateTo(1);
      } else if (jiggle.status.isCompleted) {
        jiggle.animateTo(0);
      } else {
        jiggle.addListener(_loopBack);
      }
    }
  }

  final JiggleStache jiggle;
  final WidgetStates? states;

  static final stache = Path()
    ..moveTo(38, 10)
    ..cubicTo(28, 15, 19, 10, 25, 1)
    ..cubicTo(15, 6, 20, 21, 27, 24)
    ..cubicTo(36, 29, 52, 23, 59, 15)
    ..cubicTo(65, 25, 85, 29, 93, 23)
    ..cubicTo(100, 19, 103, 6, 93, 1)
    ..cubicTo(100, 10, 90, 15, 79, 10)
    ..lineTo(84, 9)
    ..cubicTo(80, 9, 76, 7, 71, 3)
    ..cubicTo(67, 0, 63, 0, 59, 4)
    ..cubicTo(55, 0, 51, 0, 47, 3)
    ..cubicTo(42, 7, 38, 9, 34, 9)
    ..close();

  static final hat = Path()
    ..moveTo(85, 69)
    ..cubicTo(81, 69, 77, 68, 71, 67)
    ..cubicTo(82, 68, 90, 65, 95, 58)
    ..cubicTo(97, 56, 100, 52, 100, 46)
    ..cubicTo(100, 52, 100, 59, 93, 65)
    ..cubicTo(107, 61, 114, 34, 87, 28)
    ..cubicTo(78, 25, 68, 38, 49, 29)
    ..cubicTo(67, 32, 73, 23, 85, 23)
    ..cubicTo(75, -11, 28, 16, 41, 38)
    ..cubicTo(34, 34, 37, 25, 34, 23)
    ..cubicTo(20, 14, 04, 47, 23, 56)
    ..cubicTo(33, 60, 43, 54, 53, 59)
    ..cubicTo(40, 58, 36, 62, 27, 61)
    ..cubicTo(-3, 57, 09, 13, 31, 19)
    ..cubicTo(34, 20, 36, 20, 37, 18)
    ..cubicTo(51, -5, 85, -3, 91, 23)
    ..cubicTo(113, 29, 118, 65, 90, 69)
    ..cubicTo(89, 79, 89, 88, 90, 95)
    ..cubicTo(74, 90, 60, 89, 48, 93)
    ..cubicTo(65, 93, 74, 94, 87, 100)
    ..cubicTo(64, 96, 47, 98, 31, 102)
    ..cubicTo(32, 93, 34, 73, 31, 63)
    ..cubicTo(37, 70, 37, 85, 37, 92)
    ..cubicTo(53, 83, 68, 84, 86, 91)
    ..close();

  static final brown = Paint()..color = const Color(0xff403020);

  @override
  void performLayout() => size = constraints.biggest;

  @override
  void paint(PaintingContext context, Offset offset) {
    final JiggleStache(:top, :bottom) = jiggle;

    final vScale = 1 + (bottom - top) / 6;
    final hScale = 1.25 - vScale / 4;

    final Offset(:dx, :dy) = (offset & size).center - const Offset(108, 133);

    context.canvas
      ..save()
      ..translate(dx, dy)
      ..scale(1.8, 1.8)
      ..drawPath(hat, brown)
      ..translate((1 - hScale) * 60, 120 + jiggle.top * 3)
      ..scale(hScale, vScale)
      ..drawPath(stache, brown)
      ..restore();
  }
}
