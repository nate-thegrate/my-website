import 'package:nate_thegrate/the_good_stuff.dart';

export 'animated_slide.dart';
export 'animated_value.dart';
export 'demo_button.dart';
export 'dx_button.dart';
export 'dx_card.dart';
export 'render_colored_box.dart';
export 'vs_code.dart';

extension type const DX._(RenderObjectWidget _) implements RenderObjectWidget {
  const DX() : _ = const DecoratedBox(decoration: background, child: _child);

  const DX.stack() : _ = const Stack(fit: StackFit.expand, children: [DX(), DxTransition()]);

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

  static Page<void> pageBuilder(BuildContext context, GoRouterState state) {
    if (state.extra != null) {
      return const NoTransitionPage(child: DX.stack());
    }
    return const NoTransitionPage(child: DX());
  }

  static const _child = DefaultTextStyle(
    style: TextStyle(
      inherit: false,
      color: Colors.black87,
      fontFamily: 'roboto mono',
      fontSize: 22,
      fontVariations: [FontVariation.weight(550)],
    ),
    textAlign: TextAlign.center,
    child: SizedBox.expand(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Spacer(),
          Expanded(flex: 9, child: DxButton(Route.mapping, child: Text('WidgetState\nMapping'))),
          Spacer(),
          Expanded(flex: 9, child: DxButton(Route.animation, child: Text('Animated\nValues'))),
          Spacer(),
        ],
      ),
    ),
  );
}

extension type const DemoScreen._(RouteProvider _) implements RouteProvider {
  const DemoScreen() : this._(_widget);

  static const buttonBorder = BeveledRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  static const bodyBorder = BeveledRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  );
  static const _widget = RouteProvider(
    child: ApiToggle(
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: DX.background,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: kToolbarHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    spacing: 8.0,
                    children: [
                      SizedBox(
                        width: 40,
                        child: DxButton(
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
                        child: DxButton(
                          Route.mapping,
                          border: buttonBorder,
                          child: Text('Mapping'),
                        ),
                      ),
                      SizedBox.shrink(),
                      Expanded(
                        flex: 9,
                        child: DxButton(
                          Route.animation,
                          border: buttonBorder,
                          child: Text('Animation'),
                        ),
                      ),
                    ],
                  ),
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
                          child: ColoredBox(color: Color(0xff303030)),
                        ),
                        Column(
                          children: [
                            CodeCaption(),
                            Expanded(flex: 16, child: CodeSample()),
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
  );
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
    return _ApiToggle(showImprovedVersion: useValueListenable(toggle), child: child);
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
    final bool newStuff = ApiToggle.of(context);
    final subtitle = newStuff ? 'after' : 'before';
    return Text.rich(
      TextSpan(
        children: [
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
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(inherit: false, color: Colors.white),
    );
  }
}

extension type const CodeSample._(FittedBox _) implements FittedBox {
  const CodeSample()
    : _ = const FittedBox(
        alignment: Alignment.topLeft,
        child: Padding(padding: EdgeInsets.fromLTRB(32, 8, 32, 32), child: _CodeSample()),
      );
}

class _CodeSample extends StatelessWidget {
  const _CodeSample();

  static final _themeData = ThemeData(
    textSelectionTheme: const TextSelectionThemeData(selectionColor: Color(0xff285078)),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: switch (Route.of(context)) {
        Route.mapping => const Size(600, 625),
        Route.animation => const Size(720, 633),
        _ => throw Error(),
      },
      child: Theme(data: _themeData, child: SelectionArea(child: VsCode.of(context))),
    );
  }
}
