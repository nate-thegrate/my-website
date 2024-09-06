import 'package:nate_thegrate/projects/this_site/this_site.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

class ThisSiteCard extends StatefulWidget {
  const ThisSiteCard({super.key});

  @override
  State<ThisSiteCard> createState() => _ThisSiteCardState();
}

class ColorAnimation extends ValueAnimation<Color> {
  ColorAnimation({
    required super.vsync,
    required super.initialValue,
    required super.duration,
  }) : super(lerp: Color.lerp);

  static const lightGray = Color(0xffe0e0e0);

  static Color of(BuildContext context) => context.watch<ColorAnimation>().value;
}

class _ThisSiteCardState extends State<ThisSiteCard> with SingleTickerProviderStateMixin {
  double scale = 1.0;

  late final colorAnimation = ColorAnimation(
    vsync: this,
    initialValue: ColorAnimation.lightGray,
    duration: Durations.medium1,
  );
  final states = WidgetStates();

  @override
  void initState() {
    super.initState();
    states.addListener(() {
      colorAnimation.value =
          _active.isSatisfiedBy(states) ? Colors.white : ColorAnimation.lightGray;
    });
  }

  @override
  void dispose() {
    states.dispose();
    colorAnimation.dispose();
    super.dispose();
  }

  static final _active = WidgetState.hovered | WidgetState.selected;

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
          await Future.delayed(const Seconds(2));
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
    if (recursions.value > 6) return const TheVoid.gateway();

    const stuff = Row(children: [
      Expanded(
        child: Column(children: [
          Expanded(child: _Pad(HuemanCard())),
          Expanded(child: _Pad(RecipeCard())),
        ]),
      ),
      Expanded(
        child: Column(children: [
          Expanded(child: _Pad(FlutterApisCard())),
          Expanded(child: _Pad(_CardRecursion())),
        ]),
      ),
    ]);
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
            child: SizedBox(
              width: 800,
              height: 800 * root2,
              child: RecursionCount(key: recursions, child: stuff),
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
