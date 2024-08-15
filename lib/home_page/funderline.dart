import 'dart:math' as math;

import 'package:nate_thegrate/the_good_stuff.dart';

class Funderline extends StatefulWidget {
  Funderline._(this.route, RenderBox box)
      : topLeft = box.localToGlobal(Offset.zero),
        bottomRight = _screenSize.bottomRight(
          -box.localToGlobal(box.paintBounds.bottomRight),
        );

  Funderline._fromRoute(Route route)
      : this._(route, route.key.currentContext!.findRenderObject()! as RenderBox);

  Funderline.stats(BuildContext _) : this._fromRoute(Route.stats);
  Funderline.projects(BuildContext _) : this._fromRoute(Route.projects);

  static Size get _screenSize =>
      App.context.getInheritedWidgetOfExactType<MediaQuery>()!.data.size;

  final Offset topLeft, bottomRight;
  final Route route;

  @override
  State<Funderline> createState() => _FunderlineState();
}

class _FunderlineState extends State<Funderline> with SingleTickerProviderStateMixin {
  late double left, top, right, bottom;

  late final controller = ToggleAnimation(
    vsync: this,
    duration: const Duration(milliseconds: 1750),
    reverseDuration: const Duration(milliseconds: 1000),
  );

  @override
  void initState() {
    super.initState();

    final Funderline(:topLeft, :bottomRight) = widget;
    left = topLeft.dx;
    top = topLeft.dy;
    right = bottomRight.dx;
    bottom = bottomRight.dy;

    controller
      ..addListener(() => setState(() {}))
      ..addStatusListener(statusUpdate)
      ..animateTo(1);
  }

  void statusUpdate(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        context.go(widget.route);
        // TODO: should be preloaded
        Future.delayed(Durations.short1, () => controller.animateTo(0));
      case AnimationStatus.dismissed:
        FunLink.entries[widget.route]!.remove();
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        break;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.status case AnimationStatus.forward || AnimationStatus.completed) {
      final t = controller.value;
      final x = 1 - Curves.easeOutQuart.transform(math.min(t * 2.5, 1));
      final y = 1 - Curves.easeInOutQuart.transform(math.max((t - 1) * 1.25 + 1, 0));
      return Positioned(
        left: left * x,
        top: top * y,
        right: right * x,
        bottom: bottom * y,
        child: ColoredBox(
          color: Color.lerp(FunLink.color, const Color(0xff80ffff), t)!,
          child: const SizedBox.expand(),
        ),
      );
    }
    return Positioned.fill(
      child: Opacity(
        opacity: controller.value,
        child: const ColoredBox(color: GrateColors.lightCyan),
      ),
    );
  }
}
