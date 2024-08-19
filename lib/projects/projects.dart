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
    if (isMobile) {
      return const TopBar(
        body: Center(
          child: SizedBox(
            height: 720,
            child: CarouselView(
              itemExtent: 720 * root2 / 2,
              children: [
                ProjectCard(
                  route: Route.hueman,
                  child: ColoredBox(color: Color(0xFFE6D6BC)),
                ),
                ProjectCard(
                  route: Route.flutterApis,
                  child: ColoredBox(color: Color(0xFFE6D6BC)),
                ),
                ProjectCard(
                  route: Route.recipes,
                  child: ColoredBox(color: Color(0xFFE6D6BC)),
                ),
                ProjectCard(
                  route: Route.heartCenter,
                  child: ColoredBox(color: Color(0xFFE6D6BC)),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const TopBar(
      body: Center(
        child: CustomScrollView(
          slivers: [
            // SliverAppBar(
            //   expandedHeight: 64.0,
            //   collapsedHeight: kToolbarHeight,
            //   pinned: true,
            //   automaticallyImplyLeading: false,
            //   title: Text('Published'),
            // ),
            SliverPadding(
              padding: EdgeInsets.zero,
              sliver: _SpacedGrid(
                children: [
                  ProjectCard(
                    route: Route.hueman,
                    child: ColoredBox(color: Color(0xFFE6D6BC)),
                  ),
                  ProjectCard(
                    route: Route.flutterApis,
                    child: ColoredBox(color: Color(0xFFE6D6BC)),
                  ),
                  ProjectCard(
                    route: Route.recipes,
                    child: ColoredBox(color: Color(0xFFE6D6BC)),
                  ),
                  ProjectCard(
                    route: Route.heartCenter,
                    child: ColoredBox(color: Color(0xFFE6D6BC)),
                  ),
                ],
              ),
            ),
          ],
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
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: spacing),
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
  const ProjectCard({super.key, required this.route, this.child});

  final Route route;
  final Widget? child;

  static const duration = Durations.short4;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  final _controller = OverlayPortalController();
  final states = <WidgetState>{};

  void _hover(_) {
    if (states.add(WidgetState.hovered)) setState(() {});
  }

  void _endHover(_) {
    if (states.remove(WidgetState.hovered)) setState(() {});
  }

  void _handleTapDown(_) {
    _controller.show();
    setState(() => states.add(WidgetState.pressed));
  }

  void _handleTapCancel() {
    _controller.hide();
    setState(() => states.remove(WidgetState.pressed));
  }

  void _handleTapUp(_) async {
    setState(() {
      states
        ..add(WidgetState.selected)
        ..remove(WidgetState.pressed);
    });
    await Future.delayed(ProjectCard.duration);
    if (!mounted) return;

    if (widget.route == Route.hueman) {
      launchUrlString('https://hue-man.app/');
      await Future.delayed(ProjectCard.duration);
      if (mounted) {
        _controller.hide();
        setState(() => states.remove(WidgetState.selected));
      }
    } else {
      context.go(widget.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    const scale = WidgetStateProperty<double>.fromMap({
      WidgetState.selected: 8,
      WidgetState.pressed: 1.1,
      WidgetState.hovered: 1.05,
      WidgetState.any: 1.0,
    });
    final Widget? child = switch (widget.route) {
      Route.hueman => HuemanCard(expanding: states.contains(WidgetState.selected)),
      _ => widget.child
    };
    final card = MouseRegion(
      key: GlobalObjectKey(widget.route),
      cursor: SystemMouseCursors.click,
      onEnter: _hover,
      onExit: _endHover,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedScale(
          scale: scale.resolve(states),
          duration: ProjectCard.duration,
          curve: Curves.ease,
          child: PhysicalShape(
            clipper: const ShapeBorderClipper(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
            ),
            elevation: 5,
            clipBehavior: Clip.antiAlias,
            color: Colors.grey,
            shadowColor: (WidgetState.pressed | WidgetState.hovered).isSatisfiedBy(states)
                ? Colors.black
                : Colors.black45,
            child: child,
          ),
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
