import 'dart:math' as math;
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

sealed class Source implements Widget {
  const factory Source() = _Source;
  const factory Source.gateway() = _Gateway;
  const factory Source.theApproach({required Widget child}) = TheApproach;

  static void approach() => TheApproach.approach();

  static TheSourceProvides provide() => TheSourceProvides.provide();
}

/// I sure hope this class isn't deprecated anytime soon!
class _Source extends UniqueWidget<TheSourceProvides> implements Source {
  const _Source() : super(key: const GlobalObjectKey(Source));

  @override
  TheSourceProvides createState() => TheSourceProvides.createState();
}

class _Gateway extends SizedBox implements Source {
  const _Gateway() : super.expand(key: _key, child: const ColoredBox(color: Colors.white));

  static const _key = GlobalObjectKey(_Gateway);

  static BuildContext get context => _key.currentContext!;
}

class TheApproach extends HookWidget implements Source {
  const TheApproach({super.key, required this.child});

  final Widget child;

  static final approaching = Cubit(false);

  static void approach() => approaching.value = true;

  @override
  Widget build(BuildContext context) {
    Matrix4 transform = Matrix4.identity();
    if (useTheApproach()) {
      transform = context.renderBox.getTransformTo(_Gateway.context.renderBox);
    }
    return AnimatedValue.transition(
      transform,
      curve: const Dilation(),
      duration: const Seconds(2.5),
      lerp: MatrixUtils.lerp,
      onEnd: () => Route.go(Route.source),
      builder: (context, transform) => _Approach(transform: transform, child: child),
    );
  }
}

class _Approach extends SingleChildRenderObjectWidget with RenderListenable {
  const _Approach({required ValueListenable<Matrix4> transform, super.child})
      : listenable = transform;

  @override
  final ValueListenable<Matrix4> listenable;

  @override
  RenderTransform createRenderObject(BuildContext context) {
    return RenderTransform(transform: listenable.value);
  }

  @override
  void updateRenderObject(BuildContext context, RenderTransform renderObject) {
    renderObject.transform = listenable.value;
  }
}

class Dilation extends Curve {
  const Dilation();

  static const a = 2 << 16;
  static const aInverse = 1 / a;

  @override
  double transformInternal(double t) => (math.pow(a, t - 1) - aInverse) / (1 - aInverse);
}

enum Journey { whiteVoid, sourceOfWisdom, activated }

bool useTheApproach() => useValueListenable(TheApproach.approaching);
Journey useTheSource() => useValueListenable(useMemoized(() => Source.provide().journey));

class TheSourceProvides extends State<_Source> with TickerProviderStateMixin {
  factory TheSourceProvides.provide() => const _Source().currentState!;

  TheSourceProvides.createState();

  final journey = Cubit(Journey.whiteVoid);

  @override
  void dispose() {
    journey.dispose();
    super.dispose();
  }

  static const _vessel = Stack(
    alignment: Alignment.center,
    children: [
      _Passage(),
      FractionallySizedBox.scaled(
        scale: TheSource.minScaleFactor,
        child: _InnerSource(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => _vessel;
}

class _InnerSource extends HookWidget {
  const _InnerSource();

  static const fromLight = FromLight(0.8);

  @override
  Widget build(BuildContext context) {
    final journey = useTheSource();
    const theSource = Text.rich(
      TextSpan(children: [
        TextSpan(text: 'Head over to'),
        WidgetSpan(child: _GitHubButton()),
        TextSpan(text: 'to\nsee '),
        TextSpan(
          text: 'the source ',
          style: TextStyle(color: fromLight),
        ),
        TextSpan(text: 'code\nfor this website!'),
      ]),
    );

    return AnimatedToggle.builder(
      journey != Journey.whiteVoid,
      duration: const Seconds(TheSource.seconds),
      builder: (context, value, child) => AnimatedToggle.builder(
        journey == Journey.activated,
        duration: const Seconds(TheSource.endTransitionSeconds),
        curve: Curves.easeInExpo,
        builder: (context, t, child) {
          final scale = t * 4 + 1;

          return Transform(
            transform: Matrix4.identity()..scale(scale, scale),
            child: Opacity(opacity: 1 - t, child: child),
          );
        },
        child: DefaultTextStyle(
          style: TextStyle(
            inherit: false,
            color: fromLight.withValues(alpha: value),
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          child: child!,
        ),
      ),
      child: const AnimatedOpacity(
        opacity: 1.0,
        initialOpacity: 0.0,
        duration: Seconds(TheSource.transitionSeconds / 2),
        child: FittedBox(
          child: SizedBox(width: 375, height: 150, child: theSource),
        ),
      ),
    );
  }
}

class _GitHubButton extends StatelessWidget {
  const _GitHubButton();

  static void _viewTheSource() {
    Source.provide().journey.value = Journey.activated;
  }

  @override
  Widget build(BuildContext context) {
    final alpha = DefaultTextStyle.of(context).style.color!.a;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: alpha > 0 ? _viewTheSource : null,
        child: Text(
          'GitHub',
          style: TextStyle(
            fontSize: 32,
            height: 1,
            color: const Color(0xff70a8ff).withValues(alpha: alpha),
          ),
        ),
      ),
    );
  }
}

class FromLight extends Color {
  const FromLight(double light) : super.from(alpha: 1, red: light, green: light, blue: light);
}

class _Passage extends LeafRenderObjectWidget {
  const _Passage();

  @override
  TheSource createRenderObject(BuildContext context) => TheSource();
}

class TheSource extends RenderBox with BiggestBox {
  TheSource() {
    final theVoidProvides = Source.provide();
    journey = theVoidProvides.journey;

    void theVoid() {
      if (journey.value == Journey.activated) {
        activated = totalElapsed;
        tActivated = t;
        journey.removeListener(theVoid);
      }
    }

    journey.addListener(theVoid);
    ticker = theVoidProvides.createTicker(_tick)..start();
  }

  late final Cubit<Journey> journey;
  late final Ticker ticker;

  // cycle
  static const seconds = 1.25;
  static const microseconds = (seconds * microPerSec) ~/ 1;
  static final micros = math.pow(microseconds, 1.5) as double;

  // appear
  static const transitionSeconds = 10.0;
  static const transitionMicroseconds = (transitionSeconds * microPerSec) ~/ 1;

  // end
  static const endTransitionSeconds = 4.0;
  static const endTransitionMicroseconds = (endTransitionSeconds * microPerSec) ~/ 1;

  double transition = 0.0;
  int totalElapsed = 0;
  double t = 0.0;

  int? activated;
  late final double tActivated;
  late final int endMs = activated! + endTransitionMicroseconds;

  void _tick(Duration elapsed) {
    totalElapsed = elapsed.inMicroseconds;

    if (activated case final tStart?) {
      final remainingMs = endMs - totalElapsed;
      if (remainingMs <= 0) return apotheosis();
      final stretched = math.sqrt(math.sqrt(remainingMs) * micros);
      t = (2 * (tStart - totalElapsed) / stretched + tActivated) % 1;
      transition = Curves.easeOutExpo.transform(
        math.min(remainingMs / endTransitionMicroseconds * 1.5, 1),
      );
    } else {
      t = (totalElapsed % microseconds) / microseconds;
      if (transition < 1) {
        transition = Curves.easeOutSine.transform(
          math.min(totalElapsed / transitionMicroseconds, 1),
        );
        if (transition == 1) {
          journey.value = Journey.sourceOfWisdom;
        }
      }
    }
    markNeedsPaint();
  }

  void apotheosis() async {
    ticker.dispose();
    await Future.delayed(Durations.short4);
    launchUrlString('https://github.com/nate-thegrate/my-website');
    await Future.delayed(Durations.long4);

    Route.go(Route.home);
  }

  static const rectCount = 12;
  static const baseLightness = 0.5;
  static const lightnessFactor = (1 - baseLightness) / rectCount;
  static const minScaleFactor = 2 / 3 + 1 / (rectCount + 3);
  static const inverseScaleFactor = 1 / minScaleFactor;

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(offset == Offset.zero);

    final rect = offset & size;
    final canvas = context.canvas;
    canvas.drawRect(rect, Paint()..color = const FromLight(baseLightness));
    final minScale = 1 - transition + transition * minScaleFactor;
    for (int i = 1; i <= rectCount; i++) {
      final multiplier = i + t - 1;
      final scale = math.min(
        lerpDouble(inverseScaleFactor, 1, transition)! * (2 / 3 + 1 / (multiplier + 3)),
        1.0,
      );
      canvas.drawRect(
        SourceRect(rect, scale: scale),
        Paint()..color = FromLight(baseLightness + lightnessFactor * multiplier),
      );
    }
    canvas.drawRect(
      SourceRect(rect, scale: minScale),
      Paint()..color = Colors.white,
    );
  }
}

extension type SourceRect._(Rect rect) implements Rect {
  factory SourceRect(Rect rect, {required double scale}) {
    final Size(:width, :height) = rect.size;

    final newRect = Rect.fromCenter(
      center: rect.center,
      width: width * scale,
      height: height * scale,
    );

    return SourceRect._(newRect);
  }
}
