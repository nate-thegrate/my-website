import 'package:nate_thegrate/projects/this_site/this_site.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

class ThisSiteCard extends StatelessWidget {
  const ThisSiteCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (RecursionCount.of(context).value > 0) return const _CardRecursion();

    return const Stached(direction: AxisDirection.right, child: _ThisSiteCard());
  }
}

class _ThisSiteCard extends StatefulWidget {
  const _ThisSiteCard();

  @override
  State<_ThisSiteCard> createState() => _ThisSiteCardState();
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

class _ThisSiteCardState extends State<_ThisSiteCard> with SingleTickerProviderStateMixin {
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
          TheVoid.approach();
          states.add(WidgetState.selected);
          await Future.delayed(const Seconds(5 / 3));
          TheVoid.transcend();
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

  static ValueKey<int> of(BuildContext context) {
    final key = context.findAncestorWidgetOfExactType<RecursionCount>()?.key as ValueKey<int>?;
    return ValueKey<int>(key != null ? key.value + 1 : 0);
  }
}

class _CardRecursion extends StatelessWidget {
  const _CardRecursion();

  @override
  Widget build(BuildContext context) {
    final recursions = RecursionCount.of(context);
    if (recursions.value > 6) {
      if (context.findAncestorWidgetOfExactType<FlutterApisTransition>() != null) {
        return const SizedBox.shrink();
      }
      return const TheVoid.gateway();
    }

    return ToggleBuilder(
      TheVoid.of(context),
      duration: Durations.medium1,
      builder: (context, t, child) {
        return ProjectCardTemplate(
          color: ColorAnimation.of(context),
          elevation: t * 5,
          child: child!,
        );
      },
      child: Center(
        child: IgnorePointer(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox.fromSize(
              size: MediaQuery.sizeOf(context),
              child: RecursionCount(key: recursions, child: Projects.grid),
            ),
          ),
        ),
      ),
    );
  }
}
