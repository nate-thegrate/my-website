import 'dart:math';
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class ThisSiteCard extends StatefulWidget {
  const ThisSiteCard({super.key});

  @override
  State<ThisSiteCard> createState() => _ThisSiteCardState();
}

class _ThisSiteCardState extends State<ThisSiteCard> {
  double scale = 1.0;
  final controller = OverlayPortalController();
  final _cardKey = GlobalKey();

  late final states = WidgetStates()..addListener(rebuild);

  @override
  void dispose() {
    states.dispose();
    super.dispose();
  }

  static final _active = WidgetState.hovered | WidgetState.selected;

  @override
  Widget build(BuildContext context) {
    final Widget card = AnimatedValue.builder(
      key: _cardKey,
      scale,
      duration: const Seconds(1.5),
      lerp: lerpDouble,
      builder: (context, scale, child) => AnimatedValue.builder(
        _active.isSatisfiedBy(states) ? Colors.white : const Color(0xffe0e0e0),
        duration: Durations.medium1,
        curve: Curves.ease,
        lerp: Color.lerp,
        builder: (context, color, child) => _CardRecursion(scale: scale, color: color),
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => states.add(WidgetState.hovered),
      onExit: (event) => states.remove(WidgetState.hovered),
      child: TapRegion(
        onTapInside: (event) async {
          controller.show();
          scale = 4;
          states.add(WidgetState.selected);
          await Future.delayed(const Seconds(1));
          Overlay.of(context).insert(_FadeToWhite.entry);
        },
        behavior: HitTestBehavior.opaque,
        child: OverlayPortal(
          controller: controller,
          overlayChildBuilder: (_) {
            final renderBox = context.findRenderObject()! as RenderBox;
            final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);

            return Positioned.fromRect(rect: offset & renderBox.size, child: card);
          },
          child: controller.isShowing ? null : card,
        ),
      ),
    );
  }
}

class _CardRecursion extends StatelessWidget {
  const _CardRecursion({required this.scale, required this.color, this.recursions = 1});

  final Color color;
  final double scale;
  final int recursions;

  @override
  Widget build(BuildContext context) {
    if (recursions > 6) {
      return const SizedBox.expand();
    }

    final stuff = [
      const Expanded(
        child: Column(children: [
          Expanded(child: _Pad(HuemanCard())),
          Expanded(child: _Pad(Recipes())),
        ]),
      ),
      Expanded(
        child: Column(children: [
          const Expanded(child: _Pad(FlutterApisCard())),
          Expanded(
            child: _Pad(
              _CardRecursion(
                scale: scale,
                color: color,
                recursions: recursions + 1,
              ),
            ),
          ),
        ]),
      ),
    ];
    final translation = pow(scale, 0.925).toDouble();
    return FractionalTranslation(
      translation: Offset(1 - translation, 1 - translation),
      child: Transform(
        transform: Matrix4.diagonal3Values(scale, scale, 1),
        child: ProjectCardTemplate(
          color: color,
          child: Center(
            child: IgnorePointer(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: 800,
                  height: 800 * root2,
                  child: Row(children: stuff),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pad extends Padding {
  const _Pad(Widget child) : super(padding: const EdgeInsets.all(32), child: child);
}

class _FadeToWhite extends AnimatedValue<Color> {
  const _FadeToWhite()
      : super(
          Colors.white,
          initialValue: const Color(0x00ffffff),
          duration: const Seconds(0.5),
          lerp: Color.lerp,
          onEnd: _end,
        );

  static final entry = OverlayEntry(builder: (context) => const _FadeToWhite());
  static void _end() async {
    await Future.delayed(const Seconds(0.5));
    Route.go(Route.thisSite);
    entry.remove();
  }

  @override
  Widget build(BuildContext context, Color value) {
    return Positioned.fill(child: ColoredBox(color: value));
  }
}
