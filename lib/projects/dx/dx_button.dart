import 'dart:math' as math;
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class DxButton extends StatefulWidget {
  const DxButton(
    this.route, {
    super.key,
    this.border = Rekt.defaultBorder,
    required this.child,
  });

  final Route route;

  final OutlinedBorder border;

  final Widget child;

  static const style = TextStyle(
    inherit: false,
    color: Colors.black87,
    fontFamily: 'roboto mono',
    fontSize: 22,
    fontVariations: [FontVariation.weight(550)],
  );

  @override
  State<DxButton> createState() => _DxButtonState();
}

class _DxButtonState extends State<DxButton> with SingleTickerProviderStateMixin {
  late final depth = ValueAnimation(
    vsync: this,
    initialValue: 0.0,
    duration: Durations.medium1,
    curve: Curves.ease,
    lerp: lerpDouble,
  );

  @override
  void dispose() {
    depth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const interior = RouteHighlight(
      child: SizedBox(
        width: 500,
        child: FittedBox(
          child: SizedBox(
            width: 200,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _DepthTransition(),
            ),
          ),
        ),
      ),
    );
    final OutlinedBorder border = widget.border;

    return MouseRegion(
      onEnter: (event) => depth.value = 0.98,
      onExit: (event) => depth.value = 0.0,
      child: RepaintBoundary(
        child: ClipPath(
          clipper: ShapeBorderClipper(shape: border),
          child: RektTransition(
            depth: depth,
            border: border,
            child: SplashBox(
              child: InkWell(
                onTap: () {
                  if (Route.current case Route.animation || Route.mapping) {
                    return Route.go(widget.route);
                  }
                  Rekt.getRekt(context);
                },
                overlayColor: const WidgetStateColor.fromMap({
                  WidgetState.pressed: Color(0x24000000),
                  WidgetState.hovered: Color(0x14000000),
                  WidgetState.any: Colors.black12,
                }),
                child: interior,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RouteHighlight extends SingleChildRenderObjectWidget {
  const RouteHighlight({super.key, super.child});

  Color _color(BuildContext context) {
    final Route route = findWidget<DxButton>(context).route;
    return Route.of(context) == route ? Colors.black12 : Colors.transparent;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderColoredBox(color: _color(context));
  }

  @override
  void updateRenderObject(BuildContext context, RenderColoredBox renderObject) {
    renderObject.color = _color(context);
  }
}

class _DepthTransition extends HookWidget {
  const _DepthTransition();

  @override
  Widget build(BuildContext context) {
    return DepthTransition(
      depth: useControllerFrom<_DxButtonState>((s) => s.depth),
      child: findWidget<DxButton>(context).child,
    );
  }
}

class DepthTransition extends SingleChildRenderObjectWidget with RenderListenable {
  const DepthTransition({super.key, required this.depth, super.child});

  final ValueListenable<double> depth;

  @override
  Listenable get listenable => depth;

  static Matrix4 _transformed(ValueListenable<double> depth) {
    return Matrix4.translationValues(0, depth.value * 2, 0);
  }

  @override
  RenderTransform createRenderObject(BuildContext context) {
    final renderTransform = RenderTransform(
      transform: _transformed(depth),
      filterQuality: FilterQuality.none,
    );

    return renderTransform;
  }

  @override
  void updateRenderObject(BuildContext context, RenderTransform renderObject) {
    renderObject.transform = _transformed(depth);
  }
}

class RektTransition extends SingleChildRenderObjectWidget with RenderListenable {
  const RektTransition({super.key, required this.depth, this.border, super.child});

  final ValueListenable<double> depth;
  final OutlinedBorder? border;

  @override
  Listenable get listenable => depth;

  @override
  RenderDecoratedBox createRenderObject(BuildContext context) {
    return RenderDecoratedBox(
      decoration: Rekt(depth: depth.value, border: border ?? Rekt.defaultBorder),
      configuration: createLocalImageConfiguration(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDecoratedBox renderObject) {
    renderObject.decoration = Rekt(depth: depth.value, border: border ?? Rekt.defaultBorder);
  }
}

double _lerpDouble(double a, double b, double t) => a * (1 - t) + b * t;

Rect funRectLerp(Rect a, Rect b, double t) {
  final double tWidth = Curves.easeInOutSine.transform(math.max((t - 1) * 1.5 + 1, 0.0));
  final double tHeight = Curves.easeInOutSine.transform(math.min(t * 1.5, 1.0));

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
    final RenderBox box = context.renderBox;
    final Rect rect = box.localToGlobal(Offset.zero) & box.size;
    final DxButton apiButton = switch (context) {
      Element(widget: final DxButton apiButton) => apiButton,
      _ => findWidget<DxButton>(context),
    };
    final Route route = apiButton.route;
    animation.forward();
    App.overlay.insert(
      _entry = OverlayEntry(builder: (context) {
        return SizedBox.expand(
          child: FadeTransition(
            opacity: animation,
            child: DecoratedBox(
              decoration: DX.background,
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
    final Path path = rekt.border.getOuterPath(offset & configuration.size!);
    final double depth = rekt.depth;

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

class _RenderRekt extends RenderBox with BiggestBox {
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
      await Future<void>.delayed(Durations.short3);
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

    final Rect rect = funRectLerp(this.rect, targetRect, t);

    final OutlinedBorder border = OutlinedBorder.lerp(Rekt.defaultBorder, _targetBorder, t)!;
    final painter = _RektPainter(Rekt(border: border, depth: 1.0));

    final Canvas canvas = context.canvas;
    canvas.drawPath(
      border.getOuterPath(rect),
      Paint()..color = const Color(0xff303030).withValues(alpha: t),
    );
    painter.paint(canvas, rect.topLeft, ImageConfiguration(size: rect.size));
  }
}
