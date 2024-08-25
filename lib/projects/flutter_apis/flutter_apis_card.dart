import 'dart:math';
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class FlutterApisCard extends StatefulWidget {
  const FlutterApisCard({super.key});
  static bool launching = false;

  @override
  State<FlutterApisCard> createState() => _FlutterApisCardState();
}

class _FlutterApisCardState extends State<FlutterApisCard> with TickerProviderStateMixin {
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
  bool _contains(WidgetState state) => states?.contains(state) ?? false;

  bool prepareToLaunch = false;

  void _updateAnimations() async {
    widthAnimation.animateTo(_contains(WidgetState.hovered) ? 1.0 : 0.0);
    depthAnimation.animateTo(_contains(WidgetState.pressed) ? 1.0 : 0.0);

    if (_contains(WidgetState.selected) != prepareToLaunch) {
      setState(() => prepareToLaunch = !prepareToLaunch);
      if (launchAnimation.isDismissed) {
        try {
          await launchAnimation.animateTo(1.0).orCancel;
        } on TickerCanceled {
          return;
        }
        FlutterApisCard.launching = true;

        await Future.delayed(Durations.medium1);
        if (!mounted) return;

        Route.go(Route.flutterApis, extra: const Projects());
        await Future.delayed(const Seconds(1));

        FlutterApisCard.launching = false;
        prepareToLaunch = false;
        states?.remove(WidgetState.selected);
        launchAnimation.animateTo(0, from: 0.01);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    (widthAnimation, depthAnimation, launchAnimation);
    states?.addListener(_updateAnimations);
    Future.microtask(() => precacheImage(FlutterApis.bgImage, context));
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
    if (FlutterApisCard.launching) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) => ListenableBuilder(
        listenable: listenables,
        builder: (context, _) => _build(context, constraints),
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
    final altitude = max(elevation, 0.0);
    final shadowSize = max(-elevation, 0.0);
    final visibleLetters = (width * 10).round();

    final text = TextSpan(children: [
      const TextSpan(text: '{ d'),
      TextSpan(text: 'eveloper e'.substring(0, visibleLetters)),
      const TextSpan(text: 'x'),
      TextSpan(text: 'perience'.substring(0, min(visibleLetters, 8))),
      const TextSpan(text: ' }'),
    ]);

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const DarkFlutterLogo(height: 150),
        const SizedBox(height: 64),
        DecoratedBox(
          decoration: const BoxDecoration(),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Text.rich(
              text,
              style: const TextStyle(
                fontFamily: 'roboto mono',
                fontSize: 22,
                fontVariations: [FontVariation.weight(550)],
              ),
            ),
          ),
        ),
      ],
    );

    final overflowWidth = constraints.maxWidth * (1 + width / 3);
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
                      child: Center(child: column),
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

class DarkFlutterLogo extends SizedBox {
  const DarkFlutterLogo({super.key, required double height})
      : super.square(dimension: height, child: const _FlutterLogo());

  static const color = Color(0xff202020);
}

class _FlutterLogo extends LeafRenderObjectWidget {
  const _FlutterLogo();

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderFlutterLogo();
}

class _RenderFlutterLogo extends RenderBox {
  late double scale;
  @override
  void performLayout() {
    final maxSize = constraints.biggest;
    scale = min(maxSize.width, maxSize.height) / 100;

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
    ..moveTo(62, 00)
    ..lineTo(0, 50)
    ..lineTo(18, 66)
    ..lineTo(100, 00)
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

class FlutterApisTransition extends AnimatedValue<Offset> {
  const FlutterApisTransition({super.key})
      : super(
          const Offset(0, 1),
          initialValue: Offset.zero,
          duration: Durations.medium1,
          curve: Curves.easeIn,
          lerp: Offset.lerp,
          child: const Projects(),
        );

  static const stack = Stack(
    fit: StackFit.expand,
    children: [FlutterApis(), FlutterApisTransition()],
  );

  @override
  Widget build(BuildContext context, Offset value) {
    return FractionalTranslation(translation: value, child: child);
  }
}
