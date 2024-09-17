import 'dart:async';
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.body});

  final Widget body;

  static const sections = 3;

  @override
  Widget build(BuildContext context) {
    return Stache(child: TheVoid.consume(child: _TopBar(body: body)));
  }
}

class _TopBar extends StatefulWidget {
  const _TopBar({this.body});

  final Widget? body;

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> with SingleTickerProviderStateMixin {
  late final _gapAnimation = ValueAnimation(
    vsync: this,
    initialValue: 0.0,
    duration: Duration.zero,
    lerp: lerpDouble,
  )..addListener(rebuild);

  Timer? timer;

  void openGap([_]) {
    timer = Timer(Durations.extralong4, () {
      if (!mounted) return;
      _gapAnimation.animateTo(12, duration: Durations.long2, curve: Curves.easeInOutSine);
    });
  }

  void closeGap([_]) {
    timer?.cancel();
    _gapAnimation.animateTo(0, duration: Durations.short2, curve: Curves.ease);
  }

  @override
  void dispose() {
    _gapAnimation.dispose();
    super.dispose();
  }

  final indicative = Indicative._newKey;

  @override
  Widget build(BuildContext context) {
    const barHeight = 48.0;
    const bar = DefaultTextStyle(
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black,
        letterSpacing: 0.25,
      ),
      child: IgnorePointer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 14, 8, 12),
                      child: Image(image: AssetImage('assets/images/tolls.png')),
                    ),
                    Text.rich(
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      TextSpan(children: [
                        TextSpan(
                          text: 'N',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(text: 'ATE THE GRATE'),
                      ]),
                    ),
                    SizedBox(width: 2),
                  ],
                ),
              ),
            ),
            _RouteButton(Route.stats),
            _RouteButton(Route.projects),
          ],
        ),
      ),
    );

    final gapHeight = _gapAnimation.value;
    final appBar = PreferredSize(
      preferredSize: Size.fromHeight(barHeight + gapHeight),
      child: MouseRegion(
        onEnter: openGap,
        onExit: closeGap,
        child: Column(
          children: [
            ColoredBox(
              color: GrateColors.lightCyan,
              child: SizedBox(
                height: barHeight,
                child: Stack(
                  children: [
                    Indicative(key: indicative),
                    bar,
                  ],
                ),
              ),
            ),
            if (gapHeight > 0)
              SizedBox(
                width: double.infinity,
                height: gapHeight,
                child: const ColoredBox(color: Colors.black, child: _VoidGap()),
              ),
          ],
        ),
      ),
    );

    return Scaffold(appBar: appBar, body: widget.body);
  }
}

typedef _IndiKey = GlobalKey<_IndicativeState>;

class Indicative extends StatefulWidget {
  const Indicative({super.key});

  static _IndiKey get _newKey {
    if (_key.currentContext != null) _key = _IndiKey();
    return _key;
  }

  static _IndiKey _key = _IndiKey();
  static _IndicativeState get _state => _key.currentState!;

  static ValueListenable<int> get focused => _state.focused;
  static double position = 0;

  @override
  State<Indicative> createState() => _IndicativeState();
}

class _IndicativeState extends State<Indicative> {
  final int initial = switch (Route.current) {
    Route.stats => 1,
    Route.projects => 2,
    _ => 0,
  };

  late final focused = ValueNotifier(initial);
  bool goingBack = false;
  void goBack() {
    goingBack = true;
    App.overlay.insert(NoMoreCSS.entry);
    HomePageElement.instance.fricksToGive = HomePageElement.initialFricks;
  }

  @override
  void dispose() {
    focused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const box = FractionallySizedBox(
      widthFactor: 1 / TopBar.sections,
      child: ColoredBox(color: Colors.white54, child: SizedBox.expand()),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        Indicative.position = event.position.dx / App.screenSize.width;
        int x = (Indicative.position * TopBar.sections).floor();
        if (x == TopBar.sections) x -= 1;
        focused.value = x;
      },
      onExit: (_) {
        focused.value = goingBack ? 0 : initial;
      },
      child: TapRegion(
        onTapInside: (event) => switch (focused.value) {
          1 => Route.go(Route.stats),
          2 => Route.go(Route.projects),
          _ => goBack(),
        },
        child: SizedBox.expand(
          child: ValueListenableBuilder(
            valueListenable: focused,
            builder: (context, index, child) => AnimatedAlign(
              duration: Durations.short3,
              curve: Curves.ease,
              alignment: Alignment(index * 2 / (TopBar.sections - 1) - 1, 0),
              child: box,
            ),
          ),
        ),
      ),
    );
  }
}

class _VoidGap extends LeafRenderObjectWidget {
  const _VoidGap();

  @override
  VoidGap createRenderObject(BuildContext context) => VoidGap();
}

class _VoidGapAnimation extends ValueAnimation<double> {
  _VoidGapAnimation()
      : super(
          vsync: App.vsync,
          initialValue: Indicative.position,
          duration: Duration.zero,
          lerp: lerpDouble,
        );
}

class VoidGap extends RenderBox {
  VoidGap() {
    focused.addListener(updateColor);
    updateColor();
    ticker.start();
  }

  void updateColor() {
    final index = focused.value;
    color = index == 0 ? GrateColors.tolls : const Color(0xff00ffff);
  }

  late final ticker = App.vsync.createTicker(_tick);
  late Color color;
  ValueListenable<int> focused = Indicative.focused;
  int frame = 0;
  double lastPosition = Indicative.position;
  static const rectCount = 12;
  static const cycleFrames = 33;
  final animations = [
    for (int i = 0; i < rectCount; i++) _VoidGapAnimation(),
  ];

  @override
  void performLayout() => size = constraints.biggest;

  @override
  void dispose() {
    ticker.dispose();
    focused.removeListener(updateColor);
    for (final animation in animations) {
      animation.dispose();
    }
    super.dispose();
  }

  void _tick(Duration elapsed) {
    frame = (frame + 1) % cycleFrames;
    if (frame == 0) {
      animations.removeLast().dispose();
      animations.insert(0, _VoidGapAnimation());
    }

    final newFocused = Indicative.focused;
    if (newFocused != focused) {
      focused.removeListener(updateColor);
      focused = newFocused..addListener(updateColor);
    }

    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final fullBox = offset & size;

    final position = Indicative.position;
    for (final (index, animation) in animations.indexed.toList().reversed) {
      final t = (frame + 1) / (cycleFrames * rectCount) + index / rectCount;
      final color = Color.lerp(this.color, Colors.black, t)!;
      animation.duration = Seconds(t / 2);

      if (animation.value != position) {
        animation.value = position;
      }
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(animation.value * fullBox.width, fullBox.center.dy),
          width: size.width * t / 2,
          height: fullBox.height,
        ),
        Paint()..color = color,
      );
    }
  }
}

class _RouteButton extends StatelessWidget {
  const _RouteButton(this.route);

  final Route route;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          route.name.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(letterSpacing: 0.5),
        ),
      ),
    );
  }
}

class NoMoreCSS extends LeafRenderObjectWidget {
  const NoMoreCSS({super.key});

  static final entry = OverlayEntry(builder: (_) => const NoMoreCSS());

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderNoMoreCSS();
}

class _RenderNoMoreCSS extends RenderBox {
  _RenderNoMoreCSS() {
    ticker.start();
  }

  late final ticker = App.vsync.createTicker(_tick);
  Color color = Colors.transparent;
  Color? white;

  static const fadeInMicros = 2 * microPerSec;
  static const fadeOutMicros = 1 * microPerSec;
  bool fadingIn = true;

  @override
  void performLayout() => size = constraints.biggest;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  void _tick(Duration elapsed) {
    if (fadingIn) {
      final t = elapsed.inMicroseconds / fadeInMicros;
      if (t >= 1) {
        fadingIn = false;
        Route.go(Route.home);
        return;
      }

      final hsv = HSVColor.fromAHSV(1, 40, 1, 1 - t);
      color = hsv.toColor().withValues(alpha: Curves.easeInOutSine.transform(t));
    } else {
      final t = (elapsed.inMicroseconds - fadeInMicros) / fadeOutMicros;
      if (t >= 1) {
        ticker.stop();
        return NoMoreCSS.entry.remove();
      }
      final alpha = Curves.easeInOutSine.transform(1 - t);
      color = Colors.black.withValues(alpha: alpha);
      white = Colors.white.withValues(alpha: alpha);
    }
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final rect = offset & size;
    final canvas = context.canvas;

    if (white case final color?) {
      canvas.drawRect(rect, Paint()..color = color);
    }
    canvas.drawRect(rect, Paint()..color = color);
  }
}
