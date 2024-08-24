import 'dart:math';
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class ThisSite extends StatefulWidget {
  const ThisSite({super.key});

  @override
  State<ThisSite> createState() => _ThisSiteState();
}

class _ThisSiteState extends State<ThisSite> with TickerProviderStateMixin {
  late final controller = AnimationController(vsync: this, duration: const Seconds(1.25))
    ..addListener(rebuild)
    ..repeat();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const ratio = 1 / 3;
    return DefaultTextStyle(
      style: TextStyle(
        inherit: false,
        color: const Color(0xffa0a0a0),
        fontSize: size.width / 20,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const ColoredBox(color: Color(0xfffefefe), child: SizedBox.expand()),
          AnimatedValue.builder(
            1.0,
            initialValue: 0.0,
            duration: const Seconds(3),
            lerp: lerpDouble,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (var i = 1; i <= 12; i++)
                    if (i + controller.value case final j)
                      ColoredBox(
                        color: _FromLightness(1.04 - 0.5 / j * value),
                        child: SizedBox.fromSize(
                          size: size *
                              lerpDouble(
                                1,
                                1.25 * (ratio + ((1 - ratio) / pow(j, 0.5))),
                                value,
                              )!,
                        ),
                      ),
                ],
              );
            },
          ),
          const ColoredBox(
            color: Color(0xfffefefe),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(
                    text: 'Head over to GitHub to\nsee ',
                    style: TextStyle(color: Colors.transparent),
                  ),
                  TextSpan(
                    text: 'the source ',
                    style: TextStyle(color: Color(0xffd0d0d0)),
                  ),
                  TextSpan(
                    text: 'code\nfor this website!',
                    style: TextStyle(color: Colors.transparent),
                  ),
                ])),
                _DelayFadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FromLightness extends Color {
  const _FromLightness(double lightness) : this._same((lightness * 0xff) ~/ 1);
  const _FromLightness._same(int val) : super.fromARGB(0xff, val, val, val);
}

class _DelayFadeIn extends StatefulWidget {
  const _DelayFadeIn();

  @override
  State<_DelayFadeIn> createState() => _DelayFadeInState();
}

class _DelayFadeInState extends State<_DelayFadeIn> with SingleTickerProviderStateMixin {
  late final animation = ToggleAnimation(vsync: this, duration: const Seconds(1))
    ..addListener(rebuild);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Seconds(2), () => animation.animateTo(1));
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: animation.value,
      child: const Text('Head over to GitHub to\nsee the source code\nfor this website!'),
    );
  }
}
