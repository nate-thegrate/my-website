import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class ApiButton extends StatefulWidget {
  const ApiButton(
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
  State<ApiButton> createState() => _ApiButtonState();
}

class _ApiButtonState extends State<ApiButton> with SingleTickerProviderStateMixin {
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
    final border = widget.border;

    Widget box = SizedBox(
      width: 500,
      child: FittedBox(
        child: SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DepthTransition(depth: depth, child: widget.child),
          ),
        ),
      ),
    );

    if (Route.of(context) == widget.route) {
      box = ColoredBox(color: Colors.black12, child: box);
    }

    return MouseRegion(
      onEnter: (event) => depth.value = 1.0,
      onExit: (event) => depth.value = 0.0,
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
              child: box,
            ),
          ),
        ),
      ),
    );
  }
}

class DepthTransition extends AnimatedRenderObjectWidget {
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

class RektTransition extends AnimatedRenderObjectWidget {
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
