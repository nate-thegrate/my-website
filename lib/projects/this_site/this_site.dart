import 'dart:math';
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

typedef ThisSite = Void;

/// https://github.com/flutter/flutter/issues/150459
class Void extends UniqueWidget<TheVoidProvides> {
  const Void() : super(key: const GlobalObjectKey(ThisSite));

  static TheVoidProvides provide() => const Void().currentState!;

  @override
  TheVoidProvides createState() => TheVoidProvides();
}

Journey useTheVoid() => useValueListenable(useMemoized(() => Void.provide().journey));

enum Journey implements Comparable<Journey> {
  whiteVoid,
  sourceOfWisdom,
  activated;

  bool operator >=(Journey other) => compareTo(other) >= 0;

  @override
  int compareTo(Journey other) => index.compareTo(other.index);
}

class TheVoidProvides extends State<Void> with TickerProviderStateMixin {
  final journey = ValueNotifier(Journey.whiteVoid);

  @override
  void dispose() {
    journey.dispose();
    super.dispose();
  }

  static const _vessel = Stack(
    alignment: Alignment.center,
    children: [_Passage(), _InnerSource()],
  );

  @override
  Widget build(BuildContext context) => _vessel;
}

class _InnerSource extends StatelessWidget {
  const _InnerSource();

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: MediaQuery.sizeOf(context) * TheSource.minScaleFactor,
      child: const _Deeper(),
    );
  }
}

class _Deeper extends HookWidget {
  const _Deeper();

  static const fromLight = FromLight(0.8);

  @override
  Widget build(BuildContext context) {
    final journey = useTheVoid();

    return AnimatedToggle(
      journey >= Journey.sourceOfWisdom,
      duration: const Seconds(TheSource.seconds),
      builder: (context, value, child) => AnimatedToggle(
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
            color: fromLight.withOpacity(value),
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          child: child!,
        ),
      ),
      child: const AnimatedOpacity(
        opacity: 1.0,
        initialValue: 0.0,
        duration: Seconds(TheSource.transitionSeconds / 2),
        child: FittedBox(
          child: SizedBox(
            width: 375,
            height: 150,
            child: Text.rich(TextSpan(children: [
              TextSpan(text: 'Head over to'),
              WidgetSpan(child: _GitHubButton()),
              TextSpan(text: 'to\nsee '),
              TextSpan(
                text: 'the source ',
                style: TextStyle(color: fromLight),
              ),
              TextSpan(text: 'code\nfor this website!'),
            ])),
          ),
        ),
      ),
    );
  }
}

class _GitHubButton extends StatelessWidget {
  const _GitHubButton();

  static void _viewTheSource() {
    Void.provide().journey.value = Journey.activated;
  }

  @override
  Widget build(BuildContext context) {
    final opacity = DefaultTextStyle.of(context).style.color!.opacity;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: opacity > 0 ? _viewTheSource : null,
        child: Text(
          'GitHub',
          style: TextStyle(
            fontSize: 32,
            height: 0,
            color: const Color(0xff70a8ff).withOpacity(opacity),
          ),
        ),
      ),
    );
  }
}

class FromLight extends Color {
  const FromLight(double lightness) : this._same((lightness * 0xff) ~/ 1);

  const FromLight._same(int val) : super.fromARGB(0xff, val, val, val);
}

class _Passage extends LeafRenderObjectWidget {
  const _Passage();

  @override
  TheSource createRenderObject(BuildContext context) => TheSource();
}

class TheSource extends RenderBox {
  TheSource() {
    final theVoidProvides = Void.provide();
    journey = theVoidProvides.journey;

    void theVoid() {
      if (journey.value == Journey.activated) {
        activated = totalElapsed;
        tActivated = t;
        journey.removeListener(theVoid);
      }
    }

    journey.addListener(theVoid);
    _ticker = theVoidProvides.createTicker(_tick)..start();
  }

  late final ValueNotifier<Journey> journey;
  late final Ticker _ticker;

  // cycle
  static const microPerSec = Duration.microsecondsPerSecond;
  static const seconds = 1.25;
  static const microseconds = (seconds * microPerSec) ~/ 1;
  static final micros = pow(microseconds, 1.5) as double;

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
      t = (2 * (tStart - totalElapsed) / sqrt(sqrt(remainingMs) * micros) + tActivated) % 1;
      transition = Curves.easeOutExpo.transform(
        min(remainingMs / endTransitionMicroseconds * 1.5, 1),
      );
    } else {
      t = (totalElapsed % microseconds) / microseconds;
      if (transition < 1) {
        transition = Curves.easeOutSine.transform(
          min(totalElapsed / transitionMicroseconds, 1),
        );
        if (transition == 1) {
          journey.value = Journey.sourceOfWisdom;
        }
      }
    }
    markNeedsPaint();
  }

  void apotheosis() async {
    _ticker.dispose();
    await Future.delayed(Durations.short4);
    launchUrlString('https://github.com/nate-thegrate/my-website');
    await Future.delayed(Durations.long4);

    Route.go(Route.home);
    return;
  }

  @override
  void performLayout() => size = constraints.biggest;

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
      final scale = min(
        lerpDouble(inverseScaleFactor, 1, transition)! * (2 / 3 + 1 / (i + t + 2)),
        1.0,
      );
      canvas.drawRect(
        SourceRect(rect, scale: scale),
        Paint()..color = FromLight(baseLightness + lightnessFactor * (i + t - 1)),
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
