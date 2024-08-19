import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class HuemanCard extends AnimatedValue<double> {
  const HuemanCard({super.key, required bool expanding})
      : super(
          expanding ? 1.0 : 0.0,
          duration: ProjectCard.duration,
          lerp: lerpDouble,
          curve: Curves.easeInOutSine,
        );

  static const _graphic = Column(
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
  );

  @override
  Widget build(BuildContext context, double value) {
    return ColoredBox(
      color: Color.lerp(const Color(0xffeef3f8), Colors.white, value)!,
      child: Center(
        child: Opacity(
          opacity: 1 - value,
          child: _graphic,
        ),
      ),
    );
  }
}
