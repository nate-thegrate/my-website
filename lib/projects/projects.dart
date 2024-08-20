import 'dart:math' as math;

import 'package:nate_thegrate/the_good_stuff.dart';

export 'flutter_apis/flutter_apis.dart';
export 'games/games.dart';
export 'heart_center/heart_center.dart';
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
      ProjectCard(route: Route.hueman, child: HuemanCard()),
      ProjectCard(
        route: Route.flutterApis,
        child: ProjectCardTemplate(),
      ),
      ProjectCard(
        route: Route.recipes,
        child: ProjectCardTemplate(),
      ),
      ProjectCard(
        route: Route.heartCenter,
        child: ProjectCardTemplate(),
      ),
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

class ProjectCard extends StatefulWidget {
  const ProjectCard({super.key, required this.route, this.child, this.onClicked});

  final Route route;
  final Widget? child;
  final VoidCallback? onClicked;

  static const duration = Durations.short4;

  Future<void> get pause => Future.delayed(const Seconds(0.0125));

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  /// The [BlocProvider] will [dispose] of it automatically!
  final states = WidgetStates();

  final _controller = OverlayPortalController();
  void hover(_) async {
    if (!_controller.isShowing) setState(_controller.show);
    states.add(WidgetState.hovered);
  }

  void endHover(_) async {
    if (_controller.isShowing && !states.contains(WidgetState.selected)) {
      setState(_controller.hide);
    }
    states.remove(WidgetState.hovered);
  }

  void handleTapDown(_) async {
    Future.delayed(const Seconds(0.025), () => states.add(WidgetState.pressed));
  }

  void handleTapCancel() async {
    Future.delayed(const Seconds(0.025), () => states.remove(WidgetState.pressed));
  }

  void handleTapUp(_) async {
    states
      ..add(WidgetState.selected)
      ..remove(WidgetState.pressed);

    await Future.delayed(const Seconds(10));
    widget.onClicked?.call();

    if (_controller.isShowing) setState(_controller.hide);
    if (!context.mounted) return;

    states.remove(WidgetState.selected);
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
          onTapDown: handleTapDown,
          onTapUp: handleTapUp,
          onTapCancel: handleTapCancel,
          child: widget.child,
        ),
      ),
    );
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (_) {
        final renderBox = context.findRenderObject()! as RenderBox;
        final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);
        return Positioned.fromRect(
          rect: offset & renderBox.size,
          child: card,
        );
      },
      child: _controller.isShowing ? null : card,
    );
  }
}

class ProjectCardTemplate extends PhysicalShape {
  const ProjectCardTemplate({
    super.key,
    super.elevation = defaultElevation,
    super.color = const Color(0xFFF8F1E5),
    super.shadowColor = Colors.black45,
    Widget super.child = const SizedBox.expand(),
  }) : super(
          clipper: const ShapeBorderClipper(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
          ),
          clipBehavior: Clip.antiAlias,
        );

  static const defaultElevation = 5.0;
}
