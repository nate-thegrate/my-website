import 'package:nate_thegrate/the_good_stuff.dart';

class SourceCard extends StatelessWidget {
  const SourceCard({super.key});

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

class ColorAnimation extends ValueAnimation<Color> {
  ColorAnimation({
    required super.vsync,
    required super.initialValue,
    required super.duration,
  }) : super(lerp: Color.lerp);

  static const lightGray = Color(0xffe0e0e0);
  static const offWhite = Color(0xfff0f0f0);

  static Color of(BuildContext context) => context.watch<ColorAnimation>().value;
}

class _SourceCardState extends State<_SourceCard> with SingleTickerProviderStateMixin {
  double scale = 1.0;

  late final colorAnimation = ColorAnimation(
    vsync: this,
    initialValue: ColorAnimation.lightGray,
    duration: Durations.short2,
  );
  final states = WidgetStates();
  static final active = WidgetState.hovered | WidgetState.selected;

  @override
  void initState() {
    super.initState();
    states.addListener(() {
      colorAnimation.value =
          active.isSatisfiedBy(states) ? ColorAnimation.offWhite : ColorAnimation.lightGray;
    });
    Future.delayed(Durations.long2, () => Route.current = TopBar.focused = Route.projects);
    postFrameCallback(() => HomePageElement.instance.opacity.value = 0.0);
  }

  @override
  void dispose() {
    states.dispose();
    colorAnimation.dispose();
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
          await Future.delayed(const Seconds(2.35));
          Source.transcend();
        },
        behavior: HitTestBehavior.opaque,
        child: ListenableProvider(
          create: (_) => colorAnimation,
          child: const _CardRecursion(),
        ),
      ),
    );
  }
}

class RecursionCount extends KeyedSubtree {
  const RecursionCount({required ValueKey<int> super.key, required super.child});

  static int of(BuildContext context) {
    final key = context.findAncestorWidgetOfExactType<RecursionCount>()?.key as ValueKey<int>?;
    return key != null ? key.value + 1 : 0;
  }
}

class _CardRecursion extends StatelessWidget {
  const _CardRecursion();

  @override
  Widget build(BuildContext context) {
    final recursions = RecursionCount.of(context);
    if (recursions > 6) {
      if (context.findAncestorWidgetOfExactType<DxTransition>() != null) {
        return const SizedBox.shrink();
      }
      return const Source.gateway();
    }

    return ToggleBuilder(
      Source.approaches(context),
      duration: Durations.medium1,
      builder: (context, t, child) {
        return ProjectCardTemplate(
          color: ColorAnimation.of(context),
          elevation: (1 - t) * 5,
          child: child!,
        );
      },
      child: Center(
        child: IgnorePointer(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox.fromSize(
              size: MediaQuery.sizeOf(context),
              child: RecursionCount(key: ValueKey(recursions), child: Projects.grid),
            ),
          ),
        ),
      ),
    );
  }
}
