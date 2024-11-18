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

  static final approaching = Get.it(false);

  static final noTransform = Matrix4.identity();

  static void approach() async {
    approaching.value = true;
    try {
      await getZoom
          .animateTo(1.0, curve: const Dilation(), duration: const Seconds(2.5))
          .orCancel;
    } on TickerCanceled {
      return;
    }
    Route.go(Route.source);
  }

  static final getZoom = Get.vsync();

  static Matrix4 lerpMatrix(Matrix4 a, Matrix4 b, double t) {
    return Matrix4Tween(begin: a, end: b).transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final ObjectRef<Matrix4?> transform = useRef(null);
    if (useTheApproach()) {
      transform.value ??= context.renderBox.getTransformTo(_Gateway.context.renderBox);
    }
    return MatrixTransition(
      alignment: Alignment.topLeft,
      animation: getZoom.hooked,
      onTransform: (animationValue) {
        return lerpMatrix(noTransform, transform.value ?? noTransform, getZoom.value);
      },
      child: child,
    );
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

final getJourney = Get.it(Journey.whiteVoid);

bool useTheApproach() => Ref.watch(TheApproach.approaching);

class TheSourceProvides extends State<_Source> with TickerProviderStateMixin {
  factory TheSourceProvides.provide() => const _Source().currentState!;

  TheSourceProvides.createState();

  static const _vessel = Stack(
    alignment: Alignment.center,
    children: [
      _Passage(),
      FractionallySizedBox(
        widthFactor: TheSource.minScaleFactor,
        heightFactor: TheSource.minScaleFactor,
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
    final Journey journey = Ref.watch(getJourney);
    const theSource = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Head over to'),
          WidgetSpan(child: _GitHubButton()),
          TextSpan(text: 'to\nsee '),
          TextSpan(text: 'the source ', style: TextStyle(color: fromLight)),
          TextSpan(text: 'code\nfor this website!'),
        ],
      ),
    );

    return AnimatedToggle.transition(
      journey != Journey.activated,
      duration: const Seconds(TheSource.endTransitionSeconds),
      curve: Curves.easeInExpo,
      builder: (context, animation) {
        return MatrixTransition(
          animation: animation,
          onTransform: (t) {
            final double scale = (1 - t) * 4 + 1;
            return Matrix4.identity()..scale(scale, scale);
          },
          child: FadeTransition(
            opacity: animation,
            child: AnimatedToggle.builder(
              journey != Journey.whiteVoid,
              duration: const Seconds(TheSource.seconds),
              builder: (context, value, child) {
                return DefaultTextStyle(
                  style: TextStyle(
                    inherit: false,
                    color: fromLight.withValues(alpha: value),
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  child: const _FadeIn(
                    child: FittedBox(child: SizedBox(width: 375, height: 150, child: theSource)),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _FadeIn extends SingleChildRenderObjectWidget {
  const _FadeIn({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    final animation = AnimationController(
      vsync: Vsync(),
      duration: const Seconds(TheSource.transitionSeconds / 2),
    );

    return RenderAnimatedOpacity(
      opacity: animation..forward().whenCompleteOrCancel(animation.dispose),
    );
  }
}

class _GitHubButton extends StatelessWidget {
  const _GitHubButton();

  static void _viewTheSource() {
    getJourney.value = Journey.activated;
  }

  @override
  Widget build(BuildContext context) {
    final double alpha = DefaultTextStyle.of(context).style.color!.a;

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

class TheSource extends BigBox {
  TheSource() {
    final TheSourceProvides theVoidProvides = Source.provide();
    journey = getJourney.hooked;

    void theVoid() {
      if (journey.value == Journey.activated) {
        activated = totalElapsed;
        tActivated = t;
        journey.removeListener(theVoid);
      }
    }

    journey.addListener(theVoid);
    ticker = theVoidProvides.createTicker(_tick)..start();
    postFrameCallback(() => TheApproach.approaching.value = false);
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
      final int remainingMs = endMs - totalElapsed;
      if (remainingMs <= 0) return apotheosis();
      final double stretched = math.sqrt(math.sqrt(remainingMs) * micros);
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
    await Future<void>.delayed(Durations.short4);
    launchUrlString('https://github.com/nate-thegrate/my-website');
    await Future<void>.delayed(Durations.long4);

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

    final Rect rect = offset & size;
    final Canvas canvas = context.canvas;
    canvas.drawRect(rect, Paint()..color = const FromLight(baseLightness));
    final double minScale = 1 - transition + transition * minScaleFactor;
    for (int i = 1; i <= rectCount; i++) {
      final double multiplier = i + t - 1;
      final double scale = math.min(
        lerpDouble(inverseScaleFactor, 1, transition)! * (2 / 3 + 1 / (multiplier + 3)),
        1.0,
      );
      canvas.drawRect(
        SourceRect(rect, scale: scale),
        Paint()..color = FromLight(baseLightness + lightnessFactor * multiplier),
      );
    }
    canvas.drawRect(SourceRect(rect, scale: minScale), Paint()..color = Colors.white);
  }
}

extension type SourceRect._(Rect rect) implements Rect {
  factory SourceRect(Rect rect, {required double scale}) {
    final Size(:double width, :double height) = rect.size;

    final newRect = Rect.fromCenter(
      center: rect.center,
      width: width * scale,
      height: height * scale,
    );

    return SourceRect._(newRect);
  }
}
