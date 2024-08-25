import 'dart:math' as math;

import 'package:nate_thegrate/the_good_stuff.dart';

export 'flutter_apis/flutter_apis_card.dart';
export 'flutter_apis/flutter_apis.dart';
export 'hueman/hueman_card.dart';
export 'this_site/this_site_card.dart';
export 'recipes/recipes.dart';

class Projects extends StatefulWidget {
  const Projects({super.key});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  @override
  Widget build(BuildContext context) {
    const projects = [
      ProjectButton(HuemanCard()),
      ProjectButton(FlutterApisCard()),
      ProjectButton(Recipes()),
      ThisSiteCard(),
    ];

    if (isMobile) {
      return const TopBar(
        body: Center(
          child: SizedBox(
            height: 720,
            child: CarouselView(
              itemExtent: 720 * root2 / 2,
              children: projects,
            ),
          ),
        ),
      );
    }
    return const TopBar(
      body: Center(
        child: CustomScrollView(
          slivers: [_SpacedGrid(children: projects)],
        ),
      ),
    );
  }
}

class _SpacedGrid extends StatelessWidget {
  const _SpacedGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final spacing = 24.0 + math.max(720, screenWidth) / 20;
    final padding = (screenWidth - 720 - spacing) / 2;
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: math.max(padding, spacing),
        vertical: spacing,
      ),
      sliver: SliverConstrainedCrossAxis(
        maxExtent: 720,
        sliver: SliverGrid.count(
          childAspectRatio: root2 / 2,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          crossAxisCount: screenWidth < 720 ? 1 : 2,
          children: children,
        ),
      ),
    );
  }
}

class ProjectButton extends StatefulWidget {
  const ProjectButton(this.project, {super.key});

  final Widget project;

  static const duration = Durations.short4;

  Future<void> get pause => Future.delayed(const Seconds(0.0125));

  @override
  State<ProjectButton> createState() => _ProjectButtonState();
}

class _ProjectButtonState extends State<ProjectButton> {
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
          child: widget.project,
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
