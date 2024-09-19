import 'dart:math' as math;
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

/// I sure hope this class isn't deprecated anytime soon!
class ThisSite extends UniqueWidget<TheVoidProvides> {
  const ThisSite() : super(key: const GlobalObjectKey(<void>[]));

  @override
  TheVoidProvides createState() => TheVoidProvides.createState();
}

sealed class TheVoid extends Widget {
  const factory TheVoid.gateway() = _GatewayToTheVoid;

  const factory TheVoid.consume({required Widget child}) = _ConsumeTheVoid;

  static TheVoidProvides provide() => TheVoidProvides();

  static void approach() => _ApproachTheVoid.instance.approach();

  static void transcend() => App.overlay.insert(_FadeToWhite.entry);

  static bool of(BuildContext context) => !context.watch<_ApproachTheVoid>().approaching;
}

class _FadeToWhite extends LeafRenderObjectWidget {
  const _FadeToWhite();

  static final entry = OverlayEntry(builder: (context) => const _FadeToWhite());

  @override
  _RenderFadeToWhite createRenderObject(BuildContext context) => _RenderFadeToWhite();
}

class _RenderFadeToWhite extends RenderBig {
  _RenderFadeToWhite() {
    animate();
  }

  void animate() async {
    animation.addListener(markNeedsPaint);
    try {
      await animation.animateTo(Colors.white).orCancel;
    } on TickerCanceled {
      // probs won't happen
    }
    await Future.delayed(const Seconds(0.5));
    animation.dispose();
    Route.go(Route.thisSite);
    _FadeToWhite.entry.remove();
  }

  final animation = ValueAnimation(
    vsync: App.vsync,
    initialValue: const Color(0x00ffffff),
    duration: Durations.short3,
    curve: Curves.easeInOutSine,
    lerp: Color.lerp,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(offset & size, Paint()..color = animation.value);
  }
}

class _GatewayToTheVoid extends SizedBox implements TheVoid {
  const _GatewayToTheVoid()
      : super.expand(key: _key, child: const ColoredBox(color: Colors.white));

  static const _key = GlobalObjectKey(<void>{});

  static BuildContext get context => _key.currentContext!;
}

class _ApproachTheVoid extends Bloc {
  bool approaching = false;
  void approach() {
    approaching = true;
    notifyListeners();
  }

  static _ApproachTheVoid get instance => _GatewayToTheVoid.context.read();
}

class _ConsumeTheVoid extends StatelessWidget implements TheVoid {
  const _ConsumeTheVoid({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _ApproachTheVoid(),
      child: Consumer(builder: _consume, child: child),
    );
  }

  Widget _consume(BuildContext context, _ApproachTheVoid theVoid, Widget? child) {
    return theVoid.approaching ? _ConsumedByTheVoid(context, child: child) : child!;
  }
}

class Dilation extends Curve {
  const Dilation();

  static const a = 2 << 16;
  static const aInverse = 1 / a;

  @override
  double transformInternal(double t) => (math.pow(a, t - 1) - aInverse) / (1 - aInverse);
}

class _ConsumedByTheVoid extends AnimatedValue<Matrix4> implements TheVoid {
  _ConsumedByTheVoid(BuildContext context, {super.child})
      : super(
          curve: const Dilation(),
          _box(context).getTransformTo(_box()).scaled(1.001, 1.001, 1.0),
          duration: const Seconds(2.5),
          initialValue: Matrix4.identity(),
          lerp: _lerp,
        );

  static RenderBox _box([BuildContext? context]) {
    context ??= _GatewayToTheVoid.context;
    return context.findRenderObject()! as RenderBox;
  }

  static Matrix4 _lerp(Matrix4 a, Matrix4 b, double t) {
    return Matrix4Tween(begin: a, end: b).transform(t);
  }

  @override
  Widget build(BuildContext context, Matrix4 value) {
    return Transform(transform: value, child: child);
  }
}

enum Journey { whiteVoid, sourceOfWisdom, activated }

Journey useTheVoid() => useValueListenable(useMemoized(() => TheVoid.provide().journey));

class TheVoidProvides extends State<ThisSite> with TickerProviderStateMixin {
  factory TheVoidProvides() => const ThisSite().currentState!;

  TheVoidProvides.createState();

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
    final journey = useTheVoid();

    return ToggleBuilder(
      journey != Journey.whiteVoid,
      duration: const Seconds(TheSource.seconds),
      builder: (context, value, child) => ToggleBuilder(
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
    TheVoid.provide().journey.value = Journey.activated;
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
            height: 0,
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

class TheSource extends RenderBig {
  TheSource() {
    final theVoidProvides = TheVoid.provide();
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
