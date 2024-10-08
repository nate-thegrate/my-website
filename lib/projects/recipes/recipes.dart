import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

export 'delayed_activation_hook.dart';

extension type const Recipes._(SizedBox _) implements SizedBox {
  const Recipes()
      : _ = const SizedBox.expand(
          child: ColoredBox(
            color: RecipeCard.background,
            child: DefaultTextStyle(
              style: RecipeStyle(size: 36),
              child: FittedBox(
                child: SizedBox(
                  width: 400,
                  height: 500,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Align(
                        alignment: Alignment(0, -0.6),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            inherit: false,
                            color: Color(0xffb0b0b0),
                            fontWeight: FontWeight.bold,
                            fontSize: 72,
                          ),
                          child: _ComingSoon(),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 8),
                          AnimatedText(0, 'delicious'),
                          AnimatedText(1, 'affordable'),
                          AnimatedText(2, 'whole grain'),
                          AnimatedText(3, 'sugar-free'),
                          AnimatedText(4, 'plant-based'),
                          Expanded(
                            child: _FadeInButtons(),
                          ),
                          DefaultTextStyle(
                            style: RecipeStyle(size: 60),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 10),
                                AnimatedText(8.6, 'r'),
                                AnimatedText(8.8, 'e'),
                                AnimatedText(9.0, 'c'),
                                AnimatedText(9.2, 'i'),
                                AnimatedText(9.4, 'p'),
                                AnimatedText(9.6, 'e'),
                                AnimatedText(9.8, 's'),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                      SpringDrop(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
}

class RecipeStyle extends TextStyle {
  const RecipeStyle({double? size, Color super.color = Colors.black})
      : super(
          inherit: false,
          fontFamily: 'annie use your telescope',
          fontSize: size,
        );
}

class _FadeInButtons extends HookWidget {
  const _FadeInButtons();

  static void view() => launchUrlString('https://recipes.nate-thegrate.com/');
  static void back() => Route.go(Route.projects);

  @override
  Widget build(BuildContext context) {
    final ignoring = !useDelayedActivation(6);
    const row = Row(
      children: [
        Expanded(
          child: Center(
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.only(left: 8)),
                foregroundColor: WidgetStatePropertyAll(Colors.black),
                overlayColor: WidgetStatePropertyAll(Colors.white54),
                side: WidgetStateMapper({
                  WidgetState.hovered: BorderSide(width: 2),
                  WidgetState.any: BorderSide.none,
                }),
              ),
              onPressed: back,
            ),
          ),
        ),
        OutlinedButton(
          style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(RecipeStyle(size: 36)),
            foregroundColor: WidgetStatePropertyAll(Colors.black),
            padding: WidgetStatePropertyAll(EdgeInsets.fromLTRB(28, 12, 28, 16)),
            shape: WidgetStatePropertyAll(
              ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.elliptical(40, 32)),
              ),
            ),
            side: WidgetStatePropertyAll(BorderSide(width: 2)),
            overlayColor: WidgetStateMapper({
              WidgetState.pressed: Color(0xff80ffc0),
              WidgetState.any: Color(0x80a0ffd0),
            }),
          ),
          onPressed: view,
          child: Text('preview'),
        ),
        Spacer(),
      ],
    );

    return IgnorePointer(
      ignoring: ignoring,
      child: AnimatedOpacity(
        opacity: ignoring ? 0 : 1,
        duration: Durations.long4,
        curve: Curves.easeInOutSine,
        child: row,
      ),
    );
  }
}

class AnimatedText extends HookWidget {
  const AnimatedText(this.delay, this.text, {super.key});

  final String text;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final activated = useDelayedActivation(delay / 3);

    const duration = Seconds(0.8);
    return AnimatedSlide(
      offset: activated ? Offset.zero : const Offset(0, -0.25),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: activated ? 1 : 0,
        duration: duration,
        curve: Curves.easeInOutSine,
        child: Text(text),
      ),
    );
  }
}

class _ComingSoon extends HookWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    final visible = useDelayedActivation(5);

    return Transform.rotate(
      angle: -0.5,
      child: AnimatedOpacity(
        opacity: visible ? 0.5 : 0.0,
        duration: const Seconds(1),
        curve: Curves.easeInOutSine,
        child: const Text(
          'Coming soon!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class SpringDrop extends LeafRenderObjectWidget {
  const SpringDrop({super.key});

  static const duration = Seconds(4);

  @override
  RenderBox createRenderObject(BuildContext context) => _RenderSpringDrop();
}

class _RenderSpringDrop extends RenderBox with BiggestBox {
  _RenderSpringDrop() {
    animation
      ..addListener(markNeedsPaint)
      ..value = 431;
  }

  final ValueAnimation<double> animation = ValueAnimation(
    vsync: App.vsync,
    initialValue: 0,
    duration: SpringDrop.duration,
    curve: Curves.easeOutCubic,
    lerp: lerpDouble,
  );

  @override
  void performLayout() => size = constraints.biggest;

  static final drop = Path()
    ..moveTo(5, 0)
    ..cubicTo(6, 12.5, 10, 16, 10, 25)
    ..arcToPoint(
      const Offset(0, 25),
      radius: const Radius.circular(5),
    )
    ..cubicTo(0, 16, 4, 18, 5, 0)
    ..close();

  static final crescent = Path()
    ..moveTo(3, 22)
    ..arcToPoint(const Offset(5.5, 28), radius: const Radius.circular(3.5), clockwise: false)
    ..arcToPoint(const Offset(3, 22), radius: const Radius.circular(7));

  static final fillSpring = Paint()..color = const Color(0xffa0ffd0);
  static final fillBlack = Paint()..color = Colors.black;
  static final outline = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas
      ..save()
      ..translate(offset.dx + size.width / 2 - 5, offset.dy - 30 + animation.value)
      ..drawPath(drop, fillSpring)
      ..drawPath(drop, outline)
      ..drawPath(crescent, fillBlack)
      ..restore();
  }
}
