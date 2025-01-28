import 'dart:math' as math;
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.body});

  final Widget body;

  static const sections = 3;
  static const background = Color(0xff80ffff);

  static Route get focused => _focused.value;
  static final _focused = Cubit(Route.home);
  static set focused(Route newValue) {
    _focused.value = newValue;
    if (defaultTargetPlatform case TargetPlatform.android || TargetPlatform.iOS) {
      Route.destination = newValue;
      Route.travel();
    }
  }

  static double get position => _position;
  static double _position = 0.0;
  static set position(double newValue) {
    if (newValue == position) return;
    _position = newValue;
    newValue -= TollsBox.getWidth();

    final int index = newValue < 0 ? 0 : (newValue * sections / App.screenSize.width).ceil();
    focused = Route.values[index];
  }

  static void update(PointerHoverEvent event) {
    position = event.position.dx;
  }

  static void reset(PointerExitEvent event) {
    focused = Route.destination ?? Route.current;
  }

  static const _stuff = Stache(child: Source.theApproach(child: _TopBar()));

  @override
  Widget build(BuildContext context) => _stuff;
}

final _topGap = Get.vsyncValue(0.0);

class _TopBar extends StatefulWidget {
  const _TopBar();

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> with MarkNeedsBuild {
  final gapAnimation = _topGap;

  @override
  void initState() {
    super.initState();
    gapAnimation.hooked.addListener(rebuild);
  }

  Timer? timer;

  void openGap([_]) {
    timer = Timer(Durations.extralong4, () {
      if (!mounted) return;
      gapAnimation.animateTo(18, duration: Durations.long2, curve: Curves.easeInOutSine);
    });
  }

  void closeGap([_]) {
    timer?.cancel();
    gapAnimation.animateTo(0, duration: Blank.duration, curve: Curves.ease);
  }

  @override
  void dispose() {
    gapAnimation.hooked.removeListener(rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const barHeight = 48.0;
    const bar = ColoredBox(
      color: TopBar.background,
      child: Stack(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: TopBar.update,
            onExit: TopBar.reset,
            child: TapRegion(
              onTapInside: Route.travel,
              child: SizedBox.expand(child: Indicator()),
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
                  Center(
                    child: TollsBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 2, 8, 0),
                            child: Image(image: AssetImage('assets/images/tolls.png')),
                          ),
                          Text.rich(
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'N',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                                ),
                                TextSpan(text: 'ATE THE GRATE'),
                              ],
                            ),
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
    );

    final double gapHeight = gapAnimation.value;
    final appBar = MouseRegion(
      onEnter: openGap,
      onExit: closeGap,
      child: RepaintBoundary(
        child: Column(
          children: [
            SizedBox(height: barHeight + gapHeight, child: bar),
            if (gapHeight > 0)
              SizedBox(
                width: double.infinity,
                height: gapHeight,
                child: const Stack(
                  fit: StackFit.expand,
                  children: [ColoredBox(color: Color(0xff202020), child: _VoidGap()), BlurBox()],
                ),
              ),
          ],
        ),
      ),
    );

    return ColoredBox(
      color: Colors.white,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [appBar, Expanded(child: findWidget<TopBar>(context).body)],
        ),
      ),
    );
  }
}

class TollsBox extends SingleChildRenderObjectWidget {
  const TollsBox({super.key, super.child});

  static double getWidth([BuildContext? context]) {
    final Size size = MediaQuery.sizeOf(context ?? HomePageElement.instance);
    return math.max(155.0, size.width / 3);
  }

  @override
  RenderAnimatedConstraints createRenderObject(BuildContext context) {
    return RenderAnimatedConstraints(_topGap.hooked);
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnimatedConstraints renderObject) {
    renderObject._listener();
  }
}

class RenderAnimatedConstraints extends RenderConstrainedBox {
  RenderAnimatedConstraints(this.heightAnimation)
    : super(additionalConstraints: _getConstraints(heightAnimation));

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    heightAnimation.addListener(_listener);
  }

  @override
  void detach() {
    heightAnimation.removeListener(_listener);

    super.detach();
  }

  @override
  void dispose() {
    heightAnimation.removeListener(_listener);
    super.dispose();
  }

  final ValueListenable<double> heightAnimation;

  static BoxConstraints _getConstraints(ValueListenable<double> animation) {
    return BoxConstraints.tightFor(width: TollsBox.getWidth(), height: 25 + animation.value / 2);
  }

  void _listener() {
    additionalConstraints = _getConstraints(heightAnimation);
  }
}

class BlurBox extends SingleChildRenderObjectWidget {
  const BlurBox({super.key});

  static BoxDecoration _decoration(Route route) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          if (route == Route.home) ...const [Color(0xa0c09030), Color(0x00f7b943)] else ...const [
            Color(0xa080ffff),
            Color(0x0000ffff),
          ],
          const Color(0x00ffffff),
          Colors.white,
        ],
        stops: const [0.0, 0.25, 0.75, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  @override
  RenderDecoratedBox createRenderObject(BuildContext context) {
    return RenderAnimatedDecoration<Route>(
      context,
      listenable: TopBar._focused,
      computeDecoration: _decoration,
    );
  }
}

class Indicator extends StatefulWidget {
  const Indicator({super.key});

  @override
  State<Indicator> createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator> with SingleTickerProviderStateMixin {
  EdgeInsets get _padding {
    final double tollsWidth = TollsBox.getWidth(context);
    final double othersWidth = MediaQuery.sizeOf(context).width - tollsWidth;

    return switch (TopBar.focused) {
      Route.home => EdgeInsets.only(right: othersWidth),
      Route.stats => EdgeInsets.only(left: tollsWidth, right: othersWidth / 2),
      Route.projects => EdgeInsets.only(left: tollsWidth + othersWidth / 2),
      _ => EdgeInsets.zero,
    };
  }

  late final padding = ValueAnimation(
    vsync: this,
    initialValue: _padding,
    duration: Durations.short3,
    curve: Curves.ease,
    lerp: EdgeInsets.lerp,
  );
  void _update() => padding.value = _padding;

  @override
  void initState() {
    super.initState();
    TopBar._focused.addListener(_update);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _update();
  }

  @override
  void dispose() {
    TopBar._focused.removeListener(_update);
    padding.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PaddingTransition(
      padding: padding,
      child: const SizedBox.expand(child: ColoredBox(color: Colors.white54)),
    );
  }
}

class _PaddingTransition extends SingleChildRenderObjectWidget {
  const _PaddingTransition({required this.padding, super.child});

  final ValueListenable<EdgeInsets> padding;

  @override
  RenderPadding createRenderObject(BuildContext context) {
    return _RenderAnimatedPadding(paddingAnimation: padding);
  }
}

class _RenderAnimatedPadding extends RenderPadding {
  _RenderAnimatedPadding({required this.paddingAnimation})
    : super(padding: paddingAnimation.value) {
    paddingAnimation.addListener(listener);
  }

  final ValueListenable<EdgeInsetsGeometry> paddingAnimation;
  void listener() => padding = paddingAnimation.value;

  @override
  void dispose() {
    paddingAnimation.removeListener(listener);
    super.dispose();
  }
}

class _VoidGap extends LeafRenderObjectWidget {
  const _VoidGap();

  @override
  VoidGap createRenderObject(BuildContext context) => VoidGap();
}

class VoidGap extends BigBox {
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
  final animations = [for (int i = 0; i < rectCount; i++) animation()];

  @override
  void dispose() {
    ticker.dispose();
    TopBar._focused.removeListener(updateColor);
    for (final ValueAnimation<double> animation in animations) {
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
    final Canvas canvas = context.canvas;
    final Rect fullBox = offset & size;

    final double position = TopBar.position;
    for (final (index, animation) in animations.indexed.toList().reversed) {
      final double t = (frame + 1) / (cycleFrames * rectCount) + index / rectCount;
      final Color color = Color.lerp(this.color, const Color(0xff202020), t)!;
      animation.duration = Seconds(t / 2);

      if (animation.value != position) {
        animation.value = position;
      }
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(animation.value, fullBox.center.dy),
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
  RenderBox createRenderObject(BuildContext context) => RenderNoMoreCSS();
}

class RenderNoMoreCSS extends BigBox {
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
      final double t = elapsed.inMicroseconds / fadeInMicros;
      if (t >= 1) {
        fadingIn = false;
        Route.go(Route.home);
        return;
      }

      final hsv = HSVColor.fromAHSV(1, 40, 1, 1 - t);
      color = hsv.toColor().withValues(alpha: Curves.easeInOutSine.transform(t));
    } else {
      final double t = (elapsed.inMicroseconds - fadeInMicros) / fadeOutMicros;
      if (t >= 1) {
        ticker.dispose();
        return NoMoreCSS.entry.remove();
      }
      final double alpha = 1 - Curves.easeOutCubic.transform(t);
      color = Colors.black.withValues(alpha: alpha);
      white = Colors.white.withValues(alpha: alpha);
    }
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Canvas canvas = context.canvas;

    if (white case final color?) {
      canvas.drawRect(rect, Paint()..color = color);
    }
    canvas.drawRect(rect, Paint()..color = color);
  }
}

class _BlankBox extends LeafRenderObjectWidget {
  const _BlankBox();

  @override
  RenderBox createRenderObject(BuildContext context) => Blank();
}

class Blank extends BigBox {
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
