import 'package:nate_thegrate/the_good_stuff.dart';

export 'funderline.dart';

class HomePage extends ColoredBox {
  const HomePage({super.key}) : super(color: Colors.white, child: _child);

  static const _child = DefaultTextStyle(
    style: TextStyle(
      inherit: false,
      fontFamily: 'Times New Roman',
      fontSize: 16,
      color: Colors.black,
      height: 1.125,
    ),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: SelectionArea(
        child: MouseRegion(
          cursor: SystemMouseCursors.basic,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(
                  text: 'Nate - the grate\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    height: 2.5,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
                TextSpan(
                  text: 'Thank you for visiting my website!\n'
                      'This is where I showcase my passion for Flutter things 🙂',
                ),
              ])),
              FunLink.contributions(),
              FunLink.projects(),
            ],
          ),
        ),
      ),
    ),
  );
}

class FunLink extends StatelessWidget {
  const FunLink.contributions({super.key}) : route = Route.stats;
  const FunLink.projects({super.key}) : route = Route.projects;

  final Route route;

  static const color = Color(0xff0000ee);
  static final entries = {
    Route.stats: OverlayEntry(builder: Funderline.stats),
    Route.projects: OverlayEntry(builder: Funderline.projects),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 1.5,
              child: ColoredBox(key: route.key, color: color),
            ),
          ),
          Text(
            '$route',
            style: TextStyle(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.5
                ..color = Colors.white,
            ),
          ),
          Text(
            '$route',
            style: const TextStyle(color: color),
          ),
          Positioned.fill(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TapRegion(
                behavior: HitTestBehavior.opaque,
                onTapInside: (event) {
                  if (event.buttons != kSecondaryMouseButton) {
                    Overlay.of(context).insert(entries[route]!);
                  }
                },
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
