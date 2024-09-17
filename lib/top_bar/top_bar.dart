import 'dart:async';
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key, this.body});

  final Widget? body;

  static const sections = 3;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> with SingleTickerProviderStateMixin {
  late final gapAnimation = ValueAnimation(
    vsync: this,
    initialValue: 0.0,
    duration: Duration.zero,
    lerp: lerpDouble,
  )..addListener(rebuild);

  Timer? timer;

  void openGap([_]) {
    timer = Timer(const Seconds(1), () {
      if (!mounted) return;
      gapAnimation.animateTo(12, duration: Durations.long2, curve: Curves.easeInOutSine);
    });
  }

  void closeGap([_]) {
    timer?.cancel();
    gapAnimation.animateTo(0, duration: Durations.short2, curve: Curves.ease);
  }

  @override
  void dispose() {
    gapAnimation.dispose();
    super.dispose();
  }

  final floaterKey = Floater._newKey;

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

    final gapHeight = gapAnimation.value;
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
                    Floater(key: floaterKey),
                    bar,
                  ],
                ),
              ),
            ),
            if (gapHeight > 0)
              SizedBox(
                width: double.infinity,
                height: gapHeight,
                child: const ColoredBox(color: Colors.black, child: VoidGap()),
              ),
          ],
        ),
      ),
    );

    return Stache(
      child: TheVoid.consume(
        child: Scaffold(
          appBar: appBar,
          body: widget.body,
        ),
      ),
    );
  }
}

class Floater extends StatefulWidget {
  const Floater({super.key});

  static GlobalKey<_FloaterState> get _newKey {
    if (_key.currentContext != null) _key = GlobalKey<_FloaterState>();
    return _key;
  }

  static GlobalKey<_FloaterState> _key = GlobalKey<_FloaterState>();
  static _FloaterState get _state => _key.currentState!;

  static ValueListenable<int> get focused => _state.focused;
  static double position = 0;

  @override
  State<Floater> createState() => _FloaterState();
}

class _FloaterState extends State<Floater> {
  final int initial = switch (Route.current) {
    Route.stats => 1,
    Route.projects => 2,
    _ => 0,
  };

  late final ValueNotifier<int> focused = ValueNotifier(initial);
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
        Floater.position = event.position.dx / App.screenSize.width;
        int x = (Floater.position * TopBar.sections).floor();
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

class VoidGap extends LeafRenderObjectWidget {
  const VoidGap({super.key});

  @override
  RenderBox createRenderObject(BuildContext context) => _VoidGap();
}

class _VoidGapAnimation extends ValueAnimation<double> {
  _VoidGapAnimation()
      : super(
          vsync: App.vsync,
          initialValue: Floater.position,
          duration: Duration.zero,
          lerp: lerpDouble,
        );
}

class _VoidGap extends RenderBox {
  _VoidGap() {
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
  ValueListenable<int> focused = Floater.focused;
  int frame = 0;
  double lastPosition = Floater.position;
  final animations = [
    for (int i = 0; i < 8; i++) _VoidGapAnimation(),
  ];

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void dispose() {
    ticker.dispose();
    focused.removeListener(updateColor);
    super.dispose();
  }

  void _tick(Duration elapsed) {
    frame = (frame + 1) % 60;
    if (frame == 0) {
      animations.removeLast().dispose();
      animations.insert(0, _VoidGapAnimation());
    }

    final newFocused = Floater.focused;
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

    final position = Floater.position;
    for (final (index, animation) in animations.indexed.toList().reversed) {
      final t = (frame + 1) / (120 * 4) + index / 8;
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
