import 'dart:math' as math;

import 'package:nate_thegrate/the_good_stuff.dart';

class HuemanCard extends StatelessWidget {
  const HuemanCard({super.key});

  static const _graphic = FittedBox(
    child: SizedBox(
      width: 225,
      height: 240,
      child: Column(
        mainAxisSize: .min,
        spacing: 16,
        children: [
          Expanded(
            flex: 112,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'H',
                    style: TextStyle(color: Color(0xffff0000)),
                  ),
                  TextSpan(
                    text: 'U',
                    style: TextStyle(color: Color(0xffffff00)),
                  ),
                  TextSpan(
                    text: 'E',
                    style: TextStyle(color: Color(0xff0060ff)),
                  ),
                  TextSpan(text: 'man'),
                ],
              ),
              style: TextStyle(
                fontFamily: 'gaegu',
                fontWeight: .bold,
                fontSize: 64,
                color: Color(0xff6c4b00),
                shadows: [Shadow(color: Color(0x80002040), blurRadius: 2)],
              ),
            ),
          ),
          Flexible(
            flex: 128,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: .circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xffff0000),
                    Color(0xffff00ff),
                    Color(0xff0000ff),
                    Color(0xff00ffff),
                    Color(0xff00ff00),
                    Color(0xffffff00),
                    Color(0xffff0000),
                  ],
                ),
              ),
              child: SizedBox.square(dimension: 128),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final Set<WidgetState> states = WidgetStates.of(context);
    Future<void> launch() async {
      if (!states.contains(WidgetState.selected)) return;

      launchUrlString('https://hue-man.app/');

      await Future<void>.delayed(const Seconds(1.5));
      states.remove(WidgetState.selected);
    }

    const scale = WidgetStateMapper<double>({
      WidgetState.selected: 8,
      WidgetState.pressed: 1.1,
      WidgetState.hovered: 1.05,
      WidgetState.any: 1.0,
    });

    return Stached(
      direction: .left,
      child: AnimatedScale(
        scale: scale.resolve(states),
        duration: ProjectButton.duration,
        curve: Curves.ease,
        child: AnimatedToggle.builder(
          states.contains(WidgetState.selected),
          duration: ProjectButton.duration,
          curve: Curves.easeInOutSine,
          builder: (context, value, child) => ProjectCardTemplate(
            shadowColor: (WidgetState.pressed | WidgetState.hovered).isSatisfiedBy(states)
                ? Colors.black
                : Colors.black45,
            color: .lerp(const Color(0xffeef3f8), Colors.white, value)!,
            child: Center(
              child: Opacity(opacity: 1 - math.min(value * 2, 1), child: child),
            ),
          ),
          onEnd: launch,
          child: _graphic,
        ),
      ),
    );
  }
}
