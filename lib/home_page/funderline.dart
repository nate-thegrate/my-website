import 'dart:math' as math;
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

abstract class Funderline extends LeafRenderObjectWidget {
  const Funderline(this.rect, {super.key});

  factory Funderline.fromRoute(Route route) {
    final box = route.key.currentContext!.findRenderObject()! as RenderBox;
    final rect = box.localToGlobal(Offset.zero) & box.size;

    return switch (route) {
      Route.stats => _StatsFunderline(rect),
      Route.projects => _ProjectFunderline(rect),
      _ => throw Error(),
    };
  }

  final Rect rect;

  static void show(Route route) {
    final entry = switch (route) {
      Route.stats => statsEntry,
      Route.projects => projectsEntry,
      _ => throw Error(),
    };

    App.overlay.insert(entry);
  }

  @override
  RenderFunder createRenderObject(BuildContext context);
}

final statsEntry = OverlayEntry(builder: (_) => Funderline.fromRoute(Route.stats));
final projectsEntry = OverlayEntry(builder: (_) => Funderline.fromRoute(Route.projects));

abstract class RenderFunder extends RenderBox {
  RenderFunder(this.start) {
    controller
      ..addListener(markNeedsPaint)
      ..addStatusListener(statusUpdate)
      ..forward();
  }

  Route get route;

  final ToggleAnimation controller = ToggleAnimation(
    vsync: App.vsync,
    duration: const Seconds(1.75),
    reverseDuration: const Seconds(0.75),
  );

  final Rect start;
  late Rect fullScreen;

  void statusUpdate(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        Route.go(route);
        Future.delayed(const Duration(milliseconds: 90), controller.reverse);
      case AnimationStatus.dismissed:
        (route == Route.stats ? statsEntry : projectsEntry).remove();
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
  void performLayout() {
    size = constraints.biggest;
    fullScreen = Offset.zero & size;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (controller.value > 0.25) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}

class _StatsFunderline extends Funderline {
  const _StatsFunderline(super.rect);

  @override
  RenderFunder createRenderObject(BuildContext _) => _RenderStatsFunderline(rect);
}

class _RenderStatsFunderline extends RenderFunder {
  _RenderStatsFunderline(super.start);

  late double maxWidth;
  late int rowsDown;
  late Rect targetRect;

  @override
  Route get route => Route.stats;

  static const spacing = TheDeets.itemExtent;

  @override
  void performLayout() {
    super.performLayout();
    maxWidth = math.min(size.width - 2 * Stats.insets, Stats.maxWidth);
    final baseline = start.topLeft.dy;
    rowsDown = (size.height - baseline + 8) ~/ spacing;
    targetRect = Rect.fromCenter(
      center: Offset(fullScreen.center.dx, start.center.dy),
      width: maxWidth,
      height: 2,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final ToggleAnimation(:status, value: t) = controller;
    final canvas = context.canvas;

    if (status.isForwardOrCompleted) {
      final alpha = math.min(t * 2.5, 1.0);
      final x = Curves.easeOutQuart.transform(alpha);
      final y = Curves.easeInOutQuart.transform(math.max((t - 1) * 1.25 + 1, 0));

      final rect = Rect.lerp(start, targetRect, x)!;
      final color = Color.lerp(
        FunLink.color,
        PullRequest.borderColor,
        Curves.easeOutSine.transform(t),
      )!;

      canvas.drawRect(start, Paint()..color = Colors.white);
      canvas.drawRect(
        fullScreen,
        Paint()..color = TheDeets.color.withValues(alpha: alpha),
      );
      if (y == 0) {
        canvas.drawRect(rect, Paint()..color = color);
      } else {
        for (int i = -2; i < rowsDown; i++) {
          canvas.drawRect(
            rect.translate(0, y * (i * spacing - 8.5)),
            Paint()..color = color,
          );
        }
      }
    } else {
      final reveal = Curves.easeInOutSine.transform(t);
      canvas.drawRect(
        Offset.zero & Size(size.width, (targetRect.top - 2 * spacing - 8) * reveal),
        Paint()..color = TheDeets.color,
      );
      for (int i = -2; i < rowsDown; i++) {
        final rect = targetRect.translate(0, i * spacing - 8);
        canvas.drawRect(
          Rect.fromLTWH(0, rect.top - spacing + 1, size.width, (spacing - 2) * reveal),
          Paint()..color = TheDeets.color,
        );
        canvas.drawRect(
          Rect.fromCenter(center: rect.center, width: rect.width, height: rect.height * reveal),
          Paint()..color = PullRequest.borderColor.withValues(alpha: reveal),
        );
      }
      final top = targetRect.bottom + (rowsDown - 1) * spacing;
      canvas.drawRect(
        Rect.fromPoints(
          Offset(0, top),
          Offset(size.width, lerpDouble(size.height, top, 1 - reveal)!),
        ),
        Paint()..color = TheDeets.color,
      );
    }
  }
}

class _ProjectFunderline extends Funderline {
  const _ProjectFunderline(super.rect);

  @override
  RenderFunder createRenderObject(BuildContext _) => _RenderProjectFunderline(rect);
}

class _RenderProjectFunderline extends RenderFunder {
  _RenderProjectFunderline(super.start);

  @override
  Route get route => Route.projects;

  @override
  void paint(PaintingContext context, Offset offset) {
    final ToggleAnimation(:status, value: t) = controller;
    final Rect rect;
    final Color color;

    if (status.isForwardOrCompleted) {
      final x = Curves.easeOutQuart.transform(math.min(t * 2.5, 1));
      final y = Curves.easeInOutQuart.transform(math.max((t - 1) * 1.25 + 1, 0));

      final Rect(:left, :width) = Rect.lerp(start, fullScreen, x)!;
      final Rect(:top, :height) = Rect.lerp(start, fullScreen, y)!;

      rect = Rect.fromLTWH(left, top, width, height);
      color = Color.lerp(FunLink.color, const Color(0xff80ffff), t)!;
    } else {
      rect = fullScreen;
      color = GrateColors.lightCyan.withValues(alpha: t);
    }

    context.canvas.drawRect(rect, Paint()..color = color);
  }
}
