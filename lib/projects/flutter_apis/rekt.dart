import 'dart:math' as math;

import 'package:nate_thegrate/the_good_stuff.dart';

double _lerpDouble(double a, double b, double t) => a * (1 - t) + b * t;

Rect funRectLerp(Rect a, Rect b, double t) {
  final tWidth = Curves.easeInOutSine.transform(math.max((t - 1) * 1.5 + 1, 0.0));
  final tHeight = Curves.easeInOutSine.transform(math.min(t * 1.5, 1.0));

  return Rect.fromLTWH(
    _lerpDouble(a.left, b.left, tWidth),
    _lerpDouble(a.top, b.top, tHeight),
    _lerpDouble(a.width, b.width, tWidth),
    _lerpDouble(a.height, b.height, tHeight),
  );
}

final class Rekt extends Decoration {
  const Rekt({this.border = defaultBorder, required this.depth});

  Rekt.lerp(Rekt a, Rekt b, double t)
      : border = OutlinedBorder.lerp(a.border, b.border, t)!,
        depth = _lerpDouble(a.depth, b.depth, t);

  final OutlinedBorder border;
  final double depth;

  static const atRest = Rekt(depth: 0.0);
  static const depressed = Rekt(depth: 1.0);

  static const _radius = Radius.circular(16);
  static const defaultBorder = BeveledRectangleBorder(borderRadius: BorderRadius.all(_radius));

  static OverlayEntry? _entry;
  static ToggleAnimation? _animation;
  static ToggleAnimation get animation => _animation ??= ToggleAnimation(
        vsync: App.vsync,
        duration: Durations.short3,
      );
  static void getRekt(BuildContext context) {
    final box = context.findRenderObject()! as RenderBox;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final ApiButton apiButton = switch (context) {
      Element(widget: final ApiButton apiButton) => apiButton,
      _ => context.findAncestorWidgetOfExactType<ApiButton>()!,
    };
    final route = apiButton.route;
    animation.forward();
    App.overlay.insert(
      _entry = OverlayEntry(builder: (context) {
        return SizedBox.expand(
          child: FadeTransition(
            opacity: animation,
            child: DecoratedBox(
              decoration: ApiButtons.decoration,
              child: _RektTransition(rect, route),
            ),
          ),
        );
      }),
    );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) => border.getOuterPath(rect);

  @override
  bool operator ==(Object other) {
    return other is Rekt && other.border == border && other.depth == depth;
  }

  @override
  int get hashCode => Object.hash(border, depth);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _RektPainter(this);
}

class _RektPainter extends BoxPainter {
  const _RektPainter(this.rekt);
  final Rekt rekt;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final path = rekt.border.getOuterPath(offset & configuration.size!);
    final depth = rekt.depth;

    canvas.save();
    canvas.drawPath(
      path,
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, depth / 3)
        ..blendMode = BlendMode.overlay,
    );
    canvas.clipPath(path);
    canvas.drawPath(
      path.shift(Offset(depth / 2, depth * 2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Color.fromRGBO(0, 0, 0, depth)
        ..strokeWidth = depth * 4
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, depth * 2),
    );
    canvas.restore();
  }
}

class _RektTransition extends LeafRenderObjectWidget {
  const _RektTransition(this.rect, this.route);

  final Rect rect;
  final Route route;

  @override
  RenderBox createRenderObject(BuildContext context) => _RenderRekt(rect, route);
}

class _RenderRekt extends RenderBox {
  _RenderRekt(this.rect, this.route) {
    ticker = App.vsync.createTicker(_tick)..start();
  }

  final Rect rect;
  final Route route;

  late final Ticker ticker;
  double t = 0.0;

  static const transitionMicros = 1.0 * microPerSec;

  void _tick(Duration elapsed) async {
    t = elapsed.inMicroseconds / transitionMicros;
    if (t >= 1) {
      ticker.dispose();

      Route.go(route);
      await Future.delayed(Durations.short3);
      try {
        await Rekt.animation.reverse().orCancel;
      } on TickerCanceled {
        // probs shouldn't happen!
      }

      Rekt._entry!.remove();
      Rekt._entry = null;
      Rekt._animation!.dispose();
      Rekt._animation = null;
    } else {
      t = Curves.easeInOutSine.transform(t);
      markNeedsPaint();
    }
  }

  static const _targetBorder = BeveledRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(offset == Offset.zero);
    final targetRect = Rect.fromLTRB(0, kToolbarHeight, size.width, size.height);

    final rect = funRectLerp(this.rect, targetRect, t);

    final border = OutlinedBorder.lerp(Rekt.defaultBorder, _targetBorder, t)!;
    final painter = _RektPainter(Rekt(border: border, depth: 1.0));

    final canvas = context.canvas;
    canvas.drawPath(
      border.getOuterPath(rect),
      Paint()..color = const Color(0xff303030).withValues(alpha: t),
    );
    painter.paint(canvas, rect.topLeft, ImageConfiguration(size: rect.size));
  }
}
