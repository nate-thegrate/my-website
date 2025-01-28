import 'package:nate_thegrate/the_good_stuff.dart';

class SourceCard extends StatelessWidget {
  const SourceCard({super.key});

  static final color = Get.vsyncValue(grey, duration: Durations.short2, curve: Curves.linear);
  static final elevation = Get.vsyncValue(5.0);

  static const grey = Color(0xffe0e0e0);
  static const offWhite = Color(0xfff0f0f0);

  @override
  Widget build(BuildContext context) {
    if (RecursionCount.of(context) > 0) return const _CardRecursion();

    return const Stached(direction: AxisDirection.right, child: _SourceCard());
  }
}

class _SourceCard extends StatefulWidget {
  const _SourceCard();

  @override
  State<_SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends State<_SourceCard> {
  double scale = 1.0;

  final states = WidgetStates();
  static final active = WidgetState.hovered | WidgetState.selected;

  @override
  void initState() {
    super.initState();
    states.addListener(() {
      SourceCard.color.value =
          active.isSatisfiedBy(states) ? SourceCard.offWhite : SourceCard.grey;
    });
    TheApproach.approaching.hooked.addListener(listener);
  }

  void listener() {
    SourceCard.elevation.value = TheApproach.approaching.value ? 0.0 : 5.0;
  }

  @override
  void dispose() {
    states.dispose();
    TheApproach.approaching.hooked.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => states.add(WidgetState.hovered),
      onExit: (event) => states.remove(WidgetState.hovered),
      child: TapRegion(
        onTapInside: (event) async {
          Source.approach();
          states.add(WidgetState.selected);
        },
        behavior: HitTestBehavior.opaque,
        child: const _CardRecursion(),
      ),
    );
  }
}

class RecursionCount extends StatelessWidget {
  const RecursionCount({super.key});

  static int of(BuildContext context) {
    final key = context.findAncestorWidgetOfExactType<_RecursionCount>()?.key as ValueKey<int>?;
    return key != null ? key.value + 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final int recursions = RecursionCount.of(context);
    if (recursions > 6) {
      if (hasAncestor<DxTransition>(context)) {
        return const SizedBox.shrink();
      }
      return const Source.gateway();
    }

    return SizedBox.fromSize(
      size: MediaQuery.sizeOf(context),
      child: _RecursionCount(key: ValueKey(recursions), child: const ProjectGrid()),
    );
  }
}

class _RecursionCount extends KeyedSubtree {
  const _RecursionCount({required ValueKey<int> super.key, required super.child});
}

class _ScreenSizedBox extends StatelessWidget {
  const _ScreenSizedBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(size: MediaQuery.sizeOf(context), child: child);
  }
}

class _CardRecursion extends SingleChildRenderObjectWidget {
  const _CardRecursion() : super(child: _child);

  static const _child = Center(
    child: IgnorePointer(
      child: FittedBox(fit: BoxFit.cover, child: _ScreenSizedBox(child: RecursionCount())),
    ),
  );

  @override
  AnimatedCard createRenderObject(BuildContext context) => AnimatedCard();
}

class AnimatedCard extends EtherealCard {
  AnimatedCard() : this._(SourceCard.color.hooked, SourceCard.elevation.hooked);

  AnimatedCard._(this.colorAnimation, this.elevationAnimation)
    : super(color: colorAnimation.value, elevation: elevationAnimation.value) {
    colorAnimation.addListener(_colorListener);
    elevationAnimation.addListener(_elevationListener);
  }

  final ValueListenable<Color> colorAnimation;
  final ValueListenable<double> elevationAnimation;

  void _colorListener() {
    color = colorAnimation.value;
  }

  void _elevationListener() {
    elevation = elevationAnimation.value;
  }

  @override
  void dispose() {
    colorAnimation.removeListener(_colorListener);
    elevationAnimation.removeListener(_elevationListener);
    super.dispose();
  }
}
