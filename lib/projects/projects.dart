import 'package:nate_thegrate/the_good_stuff.dart';

export 'flutter_apis/flutter_apis_card.dart';
export 'flutter_apis/flutter_apis.dart';
export 'hueman/hueman_card.dart';
export 'this_site/this_site_card.dart';
export 'recipes/recipes.dart';

class Projects extends StatefulWidget {
  const Projects({super.key});

  static const grid = Column(children: [
    Spacer(),
    _Expanded(
      Row(children: [
        Spacer(),
        _Expanded(ProjectButton(HuemanCard())),
        Spacer(),
        _Expanded(ProjectButton(FlutterApisCard())),
        Spacer(),
      ]),
    ),
    Spacer(),
    _Expanded(
      Row(children: [
        Spacer(),
        _Expanded(ProjectButton(RecipeCard())),
        Spacer(),
        _Expanded(ThisSiteCard()),
        Spacer(),
      ]),
    ),
    Spacer(),
  ]);

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  @override
  Widget build(BuildContext context) {
    return const TopBar(body: Projects.grid);
  }
}

class _Expanded extends Expanded {
  const _Expanded(Widget child) : super(flex: 12, child: child);
}

class ProjectButton extends StatelessWidget {
  const ProjectButton(this.child, {super.key});

  final Widget child;

  static const duration = Durations.short4;

  @override
  Widget build(BuildContext context) {
    if (RecursionCount.of(context).value > 0) return child;

    return _ProjectButton(child);
  }
}

class _ProjectButton extends StatefulWidget {
  const _ProjectButton(this.child);

  final Widget child;

  Future<void> get pause => Future.delayed(const Seconds(0.0125));

  @override
  State<_ProjectButton> createState() => _ProjectButtonState();
}

class _ProjectButtonState extends State<_ProjectButton> {
  /// The [BlocProvider] will [dispose] of it automatically!
  final states = WidgetStates();

  final _controller = OverlayPortalController();
  void _show() {
    if (!_controller.isShowing) setState(_controller.show);
  }

  void _hide() {
    if (_controller.isShowing) setState(_controller.hide);
  }

  void hover(_) async {
    states.add(WidgetState.hovered);
  }

  void endHover(_) async {
    if (!states.contains(WidgetState.selected)) {
      _hide();
    }
    states.removeAll({WidgetState.hovered, WidgetState.pressed});
  }

  void handleDownpress(_) async {
    states.add(WidgetState.pressed);
    _show();
  }

  void handlePressEnd(_) async {
    if (states.contains(WidgetState.hovered)) {
      states.add(WidgetState.selected);
    }
    states.remove(WidgetState.pressed);

    await Future.delayed(const Seconds(2));
    if (mounted) _hide();
  }

  @override
  Widget build(BuildContext context) {
    final card = BlocProvider(
      key: GlobalObjectKey(states),
      create: (_) => states,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: hover,
        onExit: endHover,
        child: GestureDetector(
          onPanDown: handleDownpress,
          onPanEnd: handlePressEnd,
          child: widget.child,
        ),
      ),
    );

    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (_) {
        final renderBox = context.findRenderObject()! as RenderBox;
        final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);

        return Positioned.fromRect(rect: offset & renderBox.size, child: card);
      },
      child: _controller.isShowing ? null : card,
    );
  }
}

class ProjectCardTemplate extends PhysicalShape {
  const ProjectCardTemplate({
    super.key,
    super.elevation = defaultElevation,
    required super.color,
    super.shadowColor = Colors.black45,
    Widget super.child = const SizedBox.expand(),
  }) : super(
          clipper: const ShapeBorderClipper(shape: shape),
          clipBehavior: Clip.antiAlias,
        );

  static const shape = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  );

  static const defaultElevation = 5.0;
}
