import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

import 'package:nate_thegrate/the_good_stuff.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.body});

  final Widget body;

  static const sections = 3;
  static const background = Color(0xff80ffff);

  static Route get focused => _focused.value;
  static final _focused = ValueNotifier(Route.home);
  static set focused(Route newValue) {
    _focused.value = newValue;
  }

  static double get position => _position;
  static double _position = 0.0;
  static set position(double newValue) {
    if (newValue == position) return;

    _position = newValue;
    final index = math.min((_position * sections).floor(), sections - 1);
    focused = Route.values[index];
  }

  static void update(PointerHoverEvent event) {
    position = event.position.dx / App.screenSize.width;
  }

  static void reset(PointerExitEvent event) {
    TopBar.focused = Route.destination ?? Route.current;
  }

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
    _gapAnimation.animateTo(0, duration: Blank.duration, curve: Curves.ease);
  }

  @override
  void dispose() {
    _gapAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const barHeight = 48.0;
    const bar = ColoredBox(
      color: TopBar.background,
      child: SizedBox(
        height: barHeight,
        child: Stack(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: TopBar.update,
              onExit: TopBar.reset,
              child: TapRegion(
                onTapInside: Route.travel,
                child: SizedBox.expand(child: _Indicator()),
              ),
            ),
            DefaultTextStyle(
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
            ),
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
            bar,
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

class _Indicator extends StatelessWidget {
  const _Indicator();

  @override
  Widget build(BuildContext context) {
    const box = FractionallySizedBox(
      widthFactor: 1 / TopBar.sections,
      child: ColoredBox(color: Colors.white54, child: SizedBox.expand()),
    );

    return ValueListenableBuilder(
      valueListenable: TopBar._focused,
      builder: (context, route, child) => AnimatedAlign(
        duration: Durations.short3,
        curve: Curves.ease,
        alignment: Alignment(route.index * 2 / (TopBar.sections - 1) - 1, 0),
        child: box,
      ),
    );
  }
}

class _VoidGap extends LeafRenderObjectWidget {
  const _VoidGap();

  @override
  VoidGap createRenderObject(BuildContext context) => VoidGap();
}

class VoidGap extends RenderBig {
  VoidGap() {
    TopBar._focused.addListener(updateColor);
    updateColor();
    ticker.start();
  }

  static ValueAnimation<double> animation() => ValueAnimation<double>(
        vsync: App.vsync,
        initialValue: TopBar.position,
        duration: Duration.zero,
        lerp: lerpDouble,
      );

  void updateColor() {
    color = switch (TopBar.focused) {
      Route.home => const Color(0xfff7b943),
      _ => const Color(0xff00ffff),
    };
  }

  late final ticker = App.vsync.createTicker(_tick);
  late Color color;
  int frame = 0;
  double lastPosition = TopBar.position;
  static const rectCount = 12;
  static const cycleFrames = 33;
  final animations = [
    for (int i = 0; i < rectCount; i++) animation(),
  ];

  @override
  void dispose() {
    ticker.dispose();
    TopBar._focused.removeListener(updateColor);
    for (final animation in animations) {
      animation.dispose();
    }
    super.dispose();
  }

  void _tick(Duration elapsed) {
    frame = (frame + 1) % cycleFrames;
    if (frame == 0) {
      animations.removeLast().dispose();
      animations.insert(0, animation());
    }
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final fullBox = offset & size;

    final position = TopBar.position;
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
  RenderBig createRenderObject(BuildContext context) => RenderNoMoreCSS();
}

class RenderNoMoreCSS extends RenderBig {
  RenderNoMoreCSS() {
    ticker = App.vsync.createTicker(_tick)..start();
  }

  late final Ticker ticker;
  Color color = Colors.transparent;
  Color? white;

  static const fadeInMicros = 2 * microPerSec;
  static const fadeOutMicros = 0.5 * microPerSec;
  bool fadingIn = true;

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
        ticker.dispose();
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

class _BlankBox extends LeafRenderObjectWidget {
  const _BlankBox();

  @override
  RenderBig createRenderObject(BuildContext context) => Blank();
}

class Blank extends RenderBig {
  Blank();
  static const duration = Durations.short2;
  static final entry = OverlayEntry(builder: (context) => const _BlankBox());

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  @override
  void paint(PaintingContext context, Offset offset) {}
}
