import 'dart:math' as math;

import 'package:nate_thegrate/the_good_stuff.dart';

class HuemanCard extends ConsumerWidget {
  const HuemanCard({super.key});

  static const _graphic = FittedBox(
    child: SizedBox(
      width: 225,
      height: 240,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'H', style: TextStyle(color: Color(0xffff0000))),
                TextSpan(text: 'U', style: TextStyle(color: Color(0xffffff00))),
                TextSpan(text: 'E', style: TextStyle(color: Color(0xff0060ff))),
                TextSpan(text: 'man'),
              ],
            ),
            style: TextStyle(
              fontFamily: 'gaegu',
              fontWeight: FontWeight.bold,
              fontSize: 64,
              color: Color(0xff6c4b00),
              shadows: [
                Shadow(color: Color(0x80002040), blurRadius: 2),
              ],
            ),
          ),
          SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: [
                Color(0xffff0000),
                Color(0xffff00ff),
                Color(0xff0000ff),
                Color(0xff00ffff),
                Color(0xff00ff00),
                Color(0xffffff00),
                Color(0xffff0000),
              ]),
            ),
            child: SizedBox.square(dimension: 128),
          ),
        ],
      ),
    ),
  );

  static (double, bool) _selector(Set<WidgetState> states) {
    const scaleMapper = WidgetStateMapper<double>({
      WidgetState.selected: 8,
      WidgetState.pressed: 1.1,
      WidgetState.hovered: 1.05,
      WidgetState.any: 1.0,
    });

    return (scaleMapper.resolve(states), states.contains(WidgetState.selected));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void launch() async {
      final states = ref.read(widgetStatesProvider.notifier);
      if (!states.satisfies(WidgetState.selected)) return;

      launchUrlString('https://hue-man.app/');
    }

    final (double scale, bool selected) = ref.watch(widgetStatesProvider.select(_selector));

    return Stached(
      direction: AxisDirection.left,
      child: AnimatedScale(
        scale: scale,
        duration: ProjectButton.duration,
        curve: Curves.ease,
        child: AnimatedToggle.builder(
          selected,
          duration: ProjectButton.duration,
          curve: Curves.easeInOutSine,
          builder: (context, t, child) => Consumer(
            builder: (context, ref, child) {
              final bool active = ref.watch(
                widgetStatesProvider.satisfies(WidgetState.pressed | WidgetState.hovered),
              );
              return ProjectCardTemplate(
                shadowColor: active ? Colors.black : Colors.black45,
                color: Color.lerp(const Color(0xffeef3f8), Colors.white, t)!,
                child: Center(
                  child: Opacity(
                    opacity: 1 - math.min(t * 2, 1),
                    child: _graphic,
                  ),
                ),
              );
            },
          ),
          onEnd: launch,
        ),
      ),
    );
  }
}
