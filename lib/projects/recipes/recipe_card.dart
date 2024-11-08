import 'dart:math' as math;

import 'package:nate_thegrate/the_good_stuff.dart';

class RecipeCard extends StatefulWidget {
  const RecipeCard({super.key});

  static const transparentBackground = Color(0x00ddffbb);
  static const background = Color(0xffddffbb);

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> with TickerProviderStateMixin {
  late final _readStates = WidgetStates.maybeOf(context);
  ToggleAnimation? _yeet;

  @override
  void initState() {
    super.initState();
    if (_readStates != null) {
      _readStates.addListener(_select);
      _yeet = ToggleAnimation(vsync: this, duration: yeetDuration);
    }
  }

  void _select() async {
    final WidgetStates? states = _readStates;
    if (states == null) return;
    _yeet?.toggle(forward: states.contains(WidgetState.dragged));

    if (selected || !states.contains(WidgetState.selected)) return;

    selected = true;
    final ValueNotifier<bool> stash = Stache._stache;
    await Future<void>.delayed(Durations.medium1);

    stash.value = true;
    await Future<void>.delayed(Durations.medium1);

    states.add(WidgetState.dragged);
    await Future<void>.delayed(yeetDuration);

    if (!mounted) return;
    App.overlay.insert(_FadeToGreen.entry);
    await Future<void>.delayed(_FadeToGreen._duration);

    stash.value = false;
    states.removeAll({WidgetState.selected, WidgetState.dragged});
    selected = false;
  }

  bool selected = false;
  @override
  void dispose() {
    _readStates?.removeListener(_select);
    _yeet?.dispose();
    super.dispose();
  }

  static const yeetDuration = Seconds(1);

  static Matrix4 yeetTransform(double t) {
    final Size(:double width, :double height) = App.screenSize;
    return Matrix4.rotationZ(math.pow(t, 1.5) * 5)
      ..storage[12] = t * width
      ..storage[13] = (2 * t * t - t) * height * 4;
  }

  @override
  Widget build(BuildContext context) {
    final Set<WidgetState> states = WidgetStates.of(context);
    return AnimatedToggle.builder(
      (WidgetState.hovered | WidgetState.selected).isSatisfiedBy(states),
      duration: Durations.medium1,
      curve: Curves.ease,
      builder: (context, t, child) {
        final card = ProjectCardTemplate(
          clipBehavior: Clip.none,
          elevation: 5 * (1 - t),
          color: RecipeCard.background,
          child: Center(
            child: MatrixTransition(
              animation: _yeet ?? const AlwaysStoppedAnimation(0),
              onTransform: yeetTransform,
              child: const FittedBox(
                child: SizedBox(
                  width: 230,
                  height: 300,
                  child: StacheStash(),
                ),
              ),
            ),
          ),
        );
        if (t == 0) return card;
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: RecipeCard.background.withValues(alpha: t),
                blurRadius: 20 * t,
                spreadRadius: 20 * t,
              ),
            ],
          ),
          child: card,
        );
      },
    );
  }
}

class JiggleStache extends ToggleAnimation {
  JiggleStache({required super.vsync}) : super(duration: const Seconds(0.18));

  double _evaluate(double Function(double) transform) {
    return isForwardOrCompleted ? transform(value) : 1 - transform(1 - value);
  }

  static double _topTransform(double t) => Curves.ease.transform(math.min(t * 2, 1));
  static double _bottomTransform(double t) => t * t * t * (16 * t * t - 35 * t + 20);

  double get top => _evaluate(_topTransform);
  double get bottom => _evaluate(_bottomTransform);
}

class StacheStash extends LeafRenderObjectWidget {
  const StacheStash({super.key});

  @override
  RenderStache createRenderObject(BuildContext context) {
    final jiggle = JiggleStache(vsync: App.vsync);
    final WidgetStates? states = WidgetStates.maybeOf(context);

    return RenderStache(jiggle, states);
  }
}

class Stached extends StatelessWidget {
  const Stached({super.key, required this.direction, required this.child});

  final AxisDirection direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    late final Offset offset = switch (direction) {
      AxisDirection.left => const Offset(-2, 0),
      AxisDirection.right => const Offset(2, 0),
      AxisDirection.up => const Offset(0, -2),
      AxisDirection.down => const Offset(0, 2),
    };

    final Offset stash = Stache.of(context) ? offset : Offset.zero;

    return AnimatedSlide(
      offset: stash,
      duration: Durations.medium1,
      curve: Curves.ease,
      child: child,
    );
  }
}

class _Stache extends InheritedWidget {
  const _Stache({required this.value, required super.child});
  final bool value;

  @override
  bool updateShouldNotify(_Stache oldWidget) => oldWidget.value != value;
}

class Stache extends HookWidget {
  const Stache({super.key, required this.child});

  final Widget child;
  static final _stache = Cubit(false);

  static const color = Color(0xff403020);

  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_Stache>()!.value;
  }

  @override
  Widget build(BuildContext context) {
    return _Stache(value: useValueListenable(_stache), child: child);
  }
}

class RenderStache extends RenderBox with BiggestBox {
  RenderStache(this.jiggle, this.states) {
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
        ..reverse();
    }
  }

  void _updateAnimation() {
    final bool isPressed = states!.contains(WidgetState.pressed);
    if (isPressed != jiggle.isForwardOrCompleted) {
      if (isPressed) {
        jiggle.forward();
      } else if (jiggle.status.isCompleted) {
        jiggle.reverse();
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

  static final brown = Paint()..color = Stache.color;

  @override
  void paint(PaintingContext context, Offset offset) {
    final JiggleStache(:double top, :double bottom) = jiggle;

    final double vScale = 1 + (bottom - top) / 6;
    final double hScale = 1.25 - vScale / 4;

    final Offset(:double dx, :double dy) = (offset & size).center - const Offset(108, 133);

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

class _FadeToGreen extends AnimatedValue<Color> {
  const _FadeToGreen()
      : super(
          value: RecipeCard.background,
          initialValue: RecipeCard.transparentBackground,
          duration: _duration,
          lerp: Color.lerp,
          onEnd: done,
        );

  static const _duration = Durations.medium1;
  static final entry = OverlayEntry(builder: (context) => const _FadeToGreen());
  static void done() {
    Route.go(Route.recipes);
    entry.remove();
  }

  @override
  Widget build(BuildContext context, Animation<Color> animation) {
    return _ColorTransition(
      listenable: animation,
      child: const SizedBox.expand(),
    );
  }
}

class _ColorTransition extends SingleChildRenderObjectWidget {
  const _ColorTransition({required this.listenable, super.child});

  final ValueListenable<Color> listenable;

  @override
  RenderColoredBox createRenderObject(BuildContext context) {
    return RenderColoredBox(color: listenable.value);
  }

  @override
  void updateRenderObject(BuildContext context, RenderColoredBox renderObject) {
    renderObject.color = listenable.value;
  }
}
