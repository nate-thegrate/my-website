import 'dart:math' as math;
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class DxCard extends HookWidget {
  const DxCard({super.key});

  static final launching = Cubit(false);

  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ApiLaunchProvider>()!.launch;
  }

  @override
  Widget build(BuildContext context) {
    return _ApiLaunchProvider(
      launch: RecursionCount.of(context) == 0 && useValueListenable(launching),
      child: const _DxCard(),
    );
  }
}

class _ApiLaunchProvider extends InheritedWidget {
  const _ApiLaunchProvider({required this.launch, required super.child});

  final bool launch;

  @override
  bool updateShouldNotify(_ApiLaunchProvider oldWidget) => launch != oldWidget.launch;
}

class _DxCard extends StatefulWidget {
  const _DxCard();

  @override
  State<_DxCard> createState() => _DxCardState();
}

class _DxCardState extends State<_DxCard> with TickerProviderStateMixin {
  late final widthAnimation = ToggleAnimation(vsync: this, duration: Durations.medium1);
  late final depthAnimation = ToggleAnimation(vsync: this, duration: Durations.short1);
  late final launchAnimation = ToggleAnimation(vsync: this, duration: Durations.medium1);

  late final widthCurved = CurvedAnimation(
    parent: widthAnimation,
    curve: Curves.ease,
    reverseCurve: Curves.easeIn,
  );

  late final listenables = Listenable.merge({widthAnimation, depthAnimation, launchAnimation});
  late final states = context.read<WidgetStates?>();

  bool prepareToLaunch = false;

  void _updateAnimations() async {
    final states = this.states;
    if (states == null) return;

    widthAnimation.toggle(
      forward: (WidgetState.hovered | WidgetState.pressed).isSatisfiedBy(states),
    );
    depthAnimation.toggle(
      forward: states.contains(WidgetState.pressed),
    );

    if (states.contains(WidgetState.selected) != prepareToLaunch) {
      setState(() => prepareToLaunch = !prepareToLaunch);
      if (!launchAnimation.isDismissed) return;
      try {
        await launchAnimation.animateTo(1.0).orCancel;
      } on TickerCanceled {
        return;
      }
      DxCard.launching.value = true;

      await Future.delayed(Durations.medium1);
      if (!mounted) return;

      states.removeAll(const {
        WidgetState.selected,
        WidgetState.hovered,
        WidgetState.pressed,
      });
      Route.go(Route.dx, extra: const Projects());
      await Future.delayed(const Seconds(1));

      DxCard.launching.value = false;
      prepareToLaunch = false;
      launchAnimation.value = 0;
    }
  }

  @override
  void initState() {
    super.initState();
    (widthAnimation, depthAnimation, launchAnimation);
    states?.addListener(_updateAnimations);
    postFrameCallback(() => precacheImage(DX.bgImage, context));
  }

  @override
  void dispose() {
    states?.removeListener(_updateAnimations);
    widthAnimation.dispose();
    depthAnimation.dispose();
    launchAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (DxCard.of(context)) {
      return const SizedBox.shrink();
    }
    return Stached(
      direction: AxisDirection.right,
      child: LayoutBuilder(
        builder: (context, constraints) => ListenableBuilder(
          listenable: listenables,
          builder: (context, _) => _build(context, constraints),
        ),
      ),
    );
  }

  Widget _build(BuildContext context, BoxConstraints constraints) {
    final width = widthCurved.value;
    const top = 5.0;
    const bottom = -2.0;
    final elevation = prepareToLaunch
        ? bottom
        : lerpDouble(top, bottom, Curves.ease.transform(depthAnimation.value))!;
    final altitude = math.max(elevation, 0.0);
    final shadowSize = math.max(-elevation, 0.0);

    final overflowWidth = constraints.maxWidth * (1 + width / 10);
    final height = constraints.maxHeight;
    final launchWidth = overflowWidth * (1 - launchAnimation.value);

    return Center(
      child: OverflowBox(
        maxWidth: launchWidth,
        maxHeight: height,
        child: PhysicalShape(
          clipper: const ShapeBorderClipper(shape: ProjectCardTemplate.shape),
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          elevation: altitude,
          child: Center(
            child: SizedBox(
              height: height,
              child: DecoratedBox(
                decoration: CardDecoration(shadowSize),
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: SizedBox(
                    width: overflowWidth,
                    height: height,
                    child: Transform.translate(
                      offset: Offset(0, -elevation / 5),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [DarkFlutterLogo(), DxText()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension type const DxText._(Widget _) implements Widget {
  const DxText()
      : _ = const FittedBox(
          fit: BoxFit.fitWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(width: 325, child: _DxText()),
          ),
        );
}

class _DxText extends HookWidget {
  const _DxText();

  @override
  Widget build(BuildContext context) {
    final value = useValueListenable(
      useAnimationFrom<_DxCardState, double>((s) => s.widthCurved),
    );
    final visibleLetters = (value * 10).round();
    final textSpan = TextSpan(children: [
      const TextSpan(text: '{ d'),
      TextSpan(text: 'eveloper e'.substring(0, visibleLetters)),
      const TextSpan(text: 'x'),
      TextSpan(text: 'perience'.substring(0, math.min(visibleLetters, 8))),
      const TextSpan(text: ' }'),
    ]);

    return Text.rich(
      textSpan,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.visible,
      style: const TextStyle(
        fontFamily: 'roboto mono',
        fontSize: 22,
        fontVariations: [FontVariation.weight(550)],
      ),
    );
  }
}

extension type const DarkFlutterLogo._(Widget _) implements Widget {
  const DarkFlutterLogo() : this._(_widget);

  static const _widget = FittedBox(
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 36),
      child: SizedBox.square(
        dimension: 150,
        child: _FlutterLogo(),
      ),
    ),
  );

  static const color = Color(0xff202020);
}

class _FlutterLogo extends LeafRenderObjectWidget {
  const _FlutterLogo();

  @override
  RenderBox createRenderObject(BuildContext context) => _RenderFlutterLogo();
}

class _RenderFlutterLogo extends RenderBox {
  late double scale;
  @override
  void performLayout() {
    final maxSize = constraints.biggest;
    scale = math.min(maxSize.width, maxSize.height) / 100;

    size = maxSize;
  }

  static final _path = Path()
    ..moveTo(62, 46)
    ..lineTo(29, 73)
    ..lineTo(62, 100)
    ..lineTo(100, 100)
    ..lineTo(67, 73)
    ..lineTo(100, 46)
    ..close()
    ..moveTo(62, 0)
    ..lineTo(0, 50)
    ..lineTo(18, 66)
    ..lineTo(100, 0)
    ..close();

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas
      ..save()
      ..translate(offset.dx, offset.dy)
      ..scale(scale * 0.8, scale)
      ..drawPath(_path, Paint()..color = DarkFlutterLogo.color)
      ..restore();
  }
}

class CardDecoration extends Decoration {
  const CardDecoration(this.shadowSize);
  final double shadowSize;

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(rect);
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return CardPainter(shadowSize);
  }
}

class CardPainter extends BoxPainter {
  const CardPainter(this.shadowSize);
  final double shadowSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;
    canvas.drawPaint(
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xffa8eaff), Color(0xffc0d0ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );
    canvas.drawPath(
      ProjectCardTemplate.shape.getInnerPath(rect.shift(const Offset(0.5, 2))),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Color.fromRGBO(0, 0, 0, shadowSize / 5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowSize),
    );
  }
}

class DxTransition extends AnimatedSlide {
  const DxTransition({super.key})
      : super(
          offset: const Offset(0, 1.2),
          initialOffset: Offset.zero,
          duration: Durations.medium3,
          curve: Curves.easeIn,
          child: const Projects(),
        );
}
