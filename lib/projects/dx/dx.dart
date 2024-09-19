import 'package:nate_thegrate/the_good_stuff.dart';

export 'demo_button.dart';
export 'dx_card.dart';
export 'title_button.dart';
export 'vs_code.dart';

class BigApiButtons extends DecoratedBox {
  const BigApiButtons({super.key}) : super(decoration: background, child: _child);

  static const bgImage = AssetImage('assets/images/gradient.png');
  static const background = BoxDecoration(
    color: Color(0xff28ffff),
    image: DecorationImage(
      alignment: Alignment.topLeft,
      fit: BoxFit.fill,
      image: bgImage,
      filterQuality: FilterQuality.none,
    ),
  );
  static const stack = Stack(
    fit: StackFit.expand,
    children: [BigApiButtons(), FlutterApisTransition()],
  );

  static const _child = DefaultTextStyle(
    style: TitleButton.style,
    textAlign: TextAlign.center,
    child: SizedBox.expand(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Spacer(),
          Expanded(
            flex: 9,
            child: TitleButton(
              Route.mapping,
              child: Text('WidgetState\nMapping'),
            ),
          ),
          Spacer(),
          Expanded(
            flex: 9,
            child: TitleButton(
              Route.animation,
              child: Text('Animated\nValues'),
            ),
          ),
          Spacer(),
        ],
      ),
    ),
  );
}

class FlutterApis extends StatelessWidget {
  const FlutterApis({super.key});

  @override
  Widget build(BuildContext context) {
    const buttonBorder = BeveledRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
    const bodyBorder = BeveledRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    );
    return const RouteProvider(
      child: ApiToggle(
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: BigApiButtons.background,
            child: DefaultTextStyle(
              style: TitleButton.style,
              textAlign: TextAlign.center,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: kToolbarHeight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(spacing: 8.0, children: [
                        SizedBox(
                          width: 40,
                          child: TitleButton(
                            Route.projects,
                            border: CircleBorder(),
                            child: SizedBox.square(
                              dimension: 200,
                              child: Icon(Icons.arrow_back, size: 125),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: TitleButton(
                            Route.mapping,
                            border: buttonBorder,
                            child: Text('Mapping'),
                          ),
                        ),
                        SizedBox.shrink(),
                        Expanded(
                          flex: 9,
                          child: TitleButton(
                            Route.animation,
                            border: buttonBorder,
                            child: Text('Animation'),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  Expanded(
                    child: ClipPath(
                      clipper: ShapeBorderClipper(shape: bodyBorder),
                      child: SizedBox.expand(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoratedBox(
                              decoration: Rekt(depth: 1.0, border: bodyBorder),
                              position: DecorationPosition.foreground,
                              child: ColoredBox(
                                color: Color(0xff303030),
                              ),
                            ),
                            Column(
                              children: [
                                CodeCaption(),
                                Expanded(
                                  flex: 16,
                                  child: CodeSample(),
                                ),
                                DemoButton(),
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ApiToggle extends HookWidget {
  const ApiToggle({super.key, required this.child});

  final Widget child;

  static final _mapping = Cubit(false);
  static final _animation = Cubit(false);

  static Cubit<bool> get toggle => switch (Route.current) {
        Route.mapping => _mapping,
        Route.animation => _animation,
        _ => throw Error(),
      };

  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ApiToggle>()!.showImprovedVersion;
  }

  @override
  Widget build(BuildContext context) {
    final ValueListenable<bool> toggle = switch (Route.of(context)) {
      Route.mapping => _mapping,
      Route.animation => _animation,
      _ => throw Error(),
    };
    return _ApiToggle(
      showImprovedVersion: useValueListenable(toggle),
      child: child,
    );
  }
}

class _ApiToggle extends InheritedWidget {
  const _ApiToggle({required this.showImprovedVersion, required super.child});

  final bool showImprovedVersion;

  @override
  bool updateShouldNotify(_ApiToggle oldWidget) {
    return oldWidget.showImprovedVersion != showImprovedVersion;
  }
}

class CodeCaption extends StatelessWidget {
  const CodeCaption({super.key});

  @override
  Widget build(BuildContext context) {
    final newStuff = ApiToggle.of(context);
    final subtitle = newStuff ? 'after' : 'before';
    return Text.rich(
      TextSpan(children: [
        const TextSpan(text: '\n'),
        TextSpan(
          text: switch ((Route.of(context), newStuff)) {
            (Route.mapping, true) => 'WidgetState mapping',
            (Route.mapping, false) => 'Widget property resolver',
            (Route.animation, true) => 'Animated Value',
            (Route.animation, false) => 'Implicitly-animated Widget',
            _ => throw Error(),
          },
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const TextSpan(text: '\n\n', style: TextStyle(fontSize: 6)),
        TextSpan(text: '($subtitle)\n', style: VsCode.defaultStyle),
      ]),
      textAlign: TextAlign.center,
      style: const TextStyle(inherit: false, color: Colors.white),
    );
  }
}

class CodeSample extends FittedBox {
  const CodeSample({super.key}) : super(alignment: Alignment.topLeft, child: _child);

  static const _child = Padding(
    padding: EdgeInsets.fromLTRB(32, 8, 32, 32),
    child: _CodeSample(),
  );
}

class _CodeSample extends StatelessWidget {
  const _CodeSample();

  static final _themeData = ThemeData(
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Color(0xff285078),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: switch (Route.of(context)) {
        Route.mapping => const Size(600, 625),
        Route.animation => const Size(720, 633),
        _ => throw Error(),
      },
      child: Theme(
        data: _themeData,
        child: SelectionArea(child: VsCode.of(context)),
      ),
    );
  }
}
