import 'package:nate_thegrate/the_good_stuff.dart';

export 'funderline.dart';

sealed class HomePage extends ColoredBox {
  const HomePage({super.child}) : super(key: HomePageElement.key, color: Colors.white);

  @override
  HomePageElement createElement() => HomePageElement(this);
}

class MobileHomePage extends HomePage {
  const MobileHomePage() : super(child: _child);

  static const textStyle = TextStyle(
    inherit: false,
    color: Color(0xff202020),
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1,
  );
  static const buttonStyle = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Color(0xff00ffff)),
    overlayColor: WidgetStatePropertyAll(Colors.white12),
    foregroundColor: WidgetStatePropertyAll(Colors.black),
    textStyle: WidgetStatePropertyAll(textStyle),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
  );

  static void stats() => Route.go(Route.stats);
  static void projects() => Route.go(Route.projects);

  static const _child = SizedBox.expand(
    child: Column(
      children: [
        Spacer(flex: 6),
        SizedBox.square(
          dimension: 200,
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(96)),
              ),
            ),
            child: ColoredBox(
              color: TopBar.background,
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 21, 24, 24),
                child: Image(image: AssetImage('assets/images/tolls.png')),
              ),
            ),
          ),
        ),
        Spacer(),
        SizedBox(
          width: 200,
          child: FittedBox(fit: BoxFit.fitWidth, child: Text('NATE', style: textStyle)),
        ),
        SizedBox(
          width: 200,
          child: FittedBox(fit: BoxFit.fitWidth, child: Text('THE GRATE', style: textStyle)),
        ),
        Spacer(flex: 3),
        FilledButton(style: buttonStyle, onPressed: stats, child: Text('stats')),
        Spacer(),
        FilledButton(style: buttonStyle, onPressed: projects, child: Text('projects')),
        Spacer(flex: 7),
      ],
    ),
  );
}

class DesktopHomePage extends HomePage {
  const DesktopHomePage() : super(child: _child);

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
              Text.rich(
                TextSpan(
                  children: [
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
                      text:
                          'Thank you for visiting my website!\n'
                          'This is where I showcase my passion for Flutter things 🙂',
                    ),
                  ],
                ),
              ),
              FunLink.contributions(),
              FunLink.projects(),
            ],
          ),
        ),
      ),
    ),
  );
}

class HomePageElement extends SingleChildRenderObjectElement {
  HomePageElement(super.widget) {
    final entry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 0,
            left: 0,
            child: FadeTransition(opacity: opacity, child: _FunPreview.box),
          ),
    );

    postFrameCallback(() => App.overlay.insert(entry));
    fricksToGive = initialFricks;
  }

  static const key = GlobalObjectKey(DesktopHomePage);
  static HomePageElement? _instance;
  static HomePageElement get instance => _instance ??= key.currentContext! as HomePageElement;

  void show([String? message]) async {
    if (--fricksToGive > 0) {
      if (message != null) {
        text.value = message;
      }
      if (opacity.isDismissed) {
        final String currentText = text.value;
        await Future<void>.delayed(Durations.short2);
        if (text.value != currentText) return;
      }
    }

    if (!text.value.contains('é')) {
      opacity.forward();
    }
  }

  void hide([_]) async {
    if (fricksToGive == 0) return;

    final String currentText = text.value;
    await Future<void>.delayed(Durations.short2);
    if (text.value == currentText && fricksToGive > 0) {
      opacity.reverse();
    }
  }

  /// A generous amount of fricks.
  static const initialFricks = 7;

  int get fricksToGive => _fricksToGive;
  int _fricksToGive = initialFricks;
  set fricksToGive(int frickCount) {
    if (frickCount == initialFricks) {
      _fricksToGive = initialFricks;
    }
    if (frickCount == _fricksToGive) return;
    _fricksToGive = frickCount;
    if (frickCount <= 0 && !text.value.contains('é')) {
      text.value = 'um... you gonna click on something?';
    }
  }

  final text = Cubit('');

  final opacity = ToggleAnimation(
    vsync: App.vsync,
    duration: Durations.short1,
    reverseDuration: Durations.long1,
  );
}

class FunLink extends StatelessWidget {
  const FunLink.contributions({super.key}) : route = Route.stats;
  const FunLink.projects({super.key}) : route = Route.projects;

  final Route route;

  static const color = Color(0xff0000ee);

  static HomePageElement get preview => HomePageElement.instance;

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
            child: SizedBox(height: 1.5, child: ColoredBox(key: route.key, color: FunLink.color)),
          ),
          Text(
            '$route',
            style: TextStyle(
              foreground:
                  Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2.5
                    ..color = Colors.white,
            ),
          ),
          Text('$route', style: const TextStyle(color: FunLink.color)),
          Positioned.fill(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (event) async {
                final String text = switch (route) {
                  Route.stats => 'read: "bragging about LOC reduction"',
                  Route.projects => 'just some things I made :)',
                  _ => throw Error(),
                };

                preview.show(text);
              },
              onExit: preview.hide,
              child: TapRegion(
                behavior: HitTestBehavior.opaque,
                onTapInside: (event) {
                  preview.opacity.value = 0;
                  if (event.buttons != kSecondaryMouseButton) {
                    TopBar.focused = route;
                    Funderline.show(route);
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

class _FunPreview extends HookWidget {
  const _FunPreview();

  static void touch([PointerEvent? _]) {
    final HomePageElement(:ValueNotifier<String> text, :ToggleAnimation opacity) =
        HomePageElement.instance;

    if (text.value.contains('...')) {
      text.value = 'touché.';
      Future<void>.delayed(const Seconds(2.5), opacity.reverse);
    }
  }

  static const box = TapRegion(
    onTapInside: touch,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 0.5, color: Colors.black12),
          right: BorderSide(width: 0.5, color: Colors.black12),
        ),
        borderRadius: BorderRadius.only(topRight: Radius.circular(4)),
        color: Color(0xffe6f0ff),
      ),
      child: DefaultTextStyle(
        style: TextStyle(inherit: false, color: Colors.black87),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: _FunPreview(),
        ),
      ),
    ),
  );

  static String useFunPreview() {
    return useValueListenable(useMemoized(() => HomePageElement.instance.text));
  }

  @override
  Widget build(BuildContext context) {
    return Text(useFunPreview());
  }
}
