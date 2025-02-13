import 'package:nate_thegrate/the_good_stuff.dart';

export 'dx/dx.dart';
export 'hueman/hueman_card.dart';
export 'recipes/recipe_card.dart';
export 'recipes/recipes.dart';
export 'the_source/the_source.dart';
export 'the_source/the_source_card.dart';

class ProjectGrid extends Column {
  const ProjectGrid({super.key})
    : super(
        children: const [
          Spacer(),
          _Expanded(
            Row(
              children: [
                Spacer(),
                _Expanded(ProjectButton(HuemanCard())),
                Spacer(),
                _Expanded(ProjectButton(DxCard())),
                Spacer(),
              ],
            ),
          ),
          Spacer(),
          _Expanded(
            Row(
              children: [
                Spacer(),
                _Expanded(ProjectButton(RecipeCard())),
                Spacer(),
                _Expanded(SourceCard()),
                Spacer(),
              ],
            ),
          ),
          Spacer(),
        ],
      );

  static const screen = TopBar(body: ProjectGrid());

  @override
  ProjectGridElement createElement() => ProjectGridElement(this);
}

class ProjectGridElement extends MultiChildRenderObjectElement {
  ProjectGridElement(ProjectGrid super.widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    if (hasAncestor<DxTransition>(this) || RecursionCount.of(this) > 0) return;

    Future<void>.delayed(Durations.long2, () => Route.current = TopBar.focused = Route.projects);
    postFrameCallback(() => HomePageElement.instance.opacity.value = 0.0);
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
    if (RecursionCount.of(context) > 0) return child;
    return _ProjectButton(child);
  }
}

class _ProjectButton extends StatefulWidget {
  const _ProjectButton(this.child);

  final Widget child;

  @override
  State<_ProjectButton> createState() => _ProjectButtonState();
}

class _ProjectButtonState extends State<_ProjectButton> {
  final _controller = OverlayPortalController();
  void _show() {
    if (!_controller.isShowing) setState(_controller.show);
  }

  void _hide() {
    if (_controller.isShowing) setState(_controller.hide);
  }

  final states = WidgetStates();

  @override
  void dispose() {
    states.dispose();
    super.dispose();
  }

  void hover([_]) async {
    states.add(WidgetState.hovered);
  }

  void endHover([_]) async {
    if (!states.contains(WidgetState.selected)) {
      _hide();
    }
    states.removeAll(const {WidgetState.hovered, WidgetState.pressed});
  }

  void handleDownpress([_]) async {
    states.addAll(const {WidgetState.hovered, WidgetState.pressed});
    _show();
  }

  void handlePan(DragUpdateDetails details) {
    context.renderBox.paintBounds.contains(details.localPosition)
        ? states.add(WidgetState.hovered)
        : states.remove(WidgetState.hovered);
  }

  void handlePressEnd([_]) async {
    if (states.contains(WidgetState.hovered)) {
      states.add(WidgetState.selected);
    }
    if (defaultTargetPlatform case TargetPlatform.iOS || TargetPlatform.android) {
      states.removeAll(const {WidgetState.hovered, WidgetState.pressed});
    } else {
      states.remove(WidgetState.pressed);
    }
    await Future<void>.delayed(const Seconds(2));
    if (mounted) _hide();
  }

  @override
  Widget build(BuildContext context) {
    final card = WidgetStatesProvider(
      key: GlobalObjectKey(states),
      states: states,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: hover,
        onExit: endHover,
        child: GestureDetector(
          onPanDown: handleDownpress,
          onPanUpdate: handlePan,
          onPanEnd: handlePressEnd,
          behavior: HitTestBehavior.opaque,
          child: widget.child,
        ),
      ),
    );

    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (_) {
        final RenderBox box = context.renderBox;
        final Offset offset = box.localToGlobal(box.paintBounds.topLeft);

        return Positioned.fromRect(rect: offset & box.size, child: card);
      },
      child: _controller.isShowing ? const SizedBox.expand() : card,
    );
  }
}

class ProjectCardTemplate extends PhysicalShape {
  const ProjectCardTemplate({
    super.key,
    super.elevation = 5.0,
    required super.color,
    super.shadowColor = Colors.black45,
    super.clipBehavior = Clip.antiAlias,
    required Widget super.child,
  }) : super(clipper: const ShapeBorderClipper(shape: shape));

  static const shape = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  );

  @override
  RenderPhysicalShape createRenderObject(BuildContext context) {
    return EtherealCard(
      clipper: clipper,
      clipBehavior: clipBehavior,
      elevation: elevation,
      color: color,
      shadowColor: shadowColor,
    );
  }
}

class EtherealCard extends RenderPhysicalShape {
  EtherealCard({
    super.clipper = const ShapeBorderClipper(shape: ProjectCardTemplate.shape),
    super.clipBehavior = Clip.antiAlias,
    required super.elevation,
    required super.color,
    super.shadowColor = Colors.black45,
  });

  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) => false;
}
