import 'dart:math';
import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class GetRekt extends Cubit<Rect?> {
  GetRekt([_]) : super(null);

  static const duration = Durations.medium1;

  static double opacityOf(BuildContext context) {
    return context.watch<GetRekt>().value == null ? 1.0 : 0.0;
  }

  late final OverlayEntry entry;

  void absolutelyRekt(Route route, OverlayState overlay) {
    entry = OverlayEntry(
      builder: (context) => DecoratedBox(
        decoration: FlutterApis.decoration,
        child: Align(
          alignment: Alignment.topLeft,
          child: _AnimatedRekt(
            Rekt.start(value!),
            Rekt.end(MediaQuery.sizeOf(context)),
            onEnd: () async {
              await Future.delayed(Durations.short4);
              entry.remove();
              Route.go(route);
            },
          ),
        ),
      ),
    );
    overlay.insert(entry);
  }
}

@immutable
class Rekt {
  const Rekt.start(this.rekt)
      : corners = const BorderRadius.all(_radius),
        color = const Color.fromRGBO(0, 0, 0, 1 / 3);

  Rekt.end(Size screensize)
      : rekt = Rect.fromLTRB(0, kToolbarHeight, screensize.width, screensize.height),
        corners = const BorderRadius.vertical(top: _radius),
        color = const Color(0xff202020);

  Rekt.lerp(Rekt a, Rekt b, double t)
      : rekt = _funRectLerp(a.rekt, b.rekt, t),
        color = Color.lerp(a.color, b.color, t)!,
        corners = BorderRadius.lerp(a.corners, b.corners, t)!;

  static Rect _funRectLerp(Rect a, Rect b, double t) {
    final tWidth = Curves.easeInOutSine.transform(max((t - 1) * 1.5 + 1, 0.0));
    final tHeight = Curves.easeInOutSine.transform(min(t * 1.5, 1.0));

    return Rect.fromLTWH(
      lerpDouble(a.left, b.left, tWidth)!,
      lerpDouble(a.top, b.top, tHeight)!,
      lerpDouble(a.width, b.width, tWidth)!,
      lerpDouble(a.height, b.height, tHeight)!,
    );
  }

  static const _radius = Radius.circular(16);

  final Rect rekt;
  final BorderRadius corners;
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is Rekt && other.rekt == rekt && other.corners == corners && other.color == color;

  @override
  int get hashCode => Object.hash(rekt, corners, color);
}

class _AnimatedRekt extends AnimatedValue<Rekt> {
  const _AnimatedRekt(Rekt start, super.end, {super.onEnd})
      : super(
          initialValue: start,
          duration: const Seconds(1),
          curve: Curves.easeInOutSine,
          lerp: Rekt.lerp,
        );

  @override
  Widget build(BuildContext context, Rekt value) {
    final rekt = value.rekt;
    return Padding(
      padding: EdgeInsets.only(top: rekt.top, left: rekt.left),
      child: SizedBox.fromSize(
        size: rekt.size,
        child: DecoratedBox(decoration: RektDecoration(rekt: value)),
      ),
    );
  }
}

class RektDecoration extends Decoration {
  const RektDecoration({this.rekt, this.depth = 1.0});
  final Rekt? rekt;
  final double depth;
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _DecorationPainter(rekt, depth);
}

class _DecorationPainter extends BoxPainter {
  const _DecorationPainter(this.rekt, this.depth);
  final Rekt? rekt;
  final double depth;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final shape = BeveledRectangleBorder(
      borderRadius: rekt?.corners ?? const BorderRadius.all(Radius.circular(16.0)),
    );

    final path = shape.getOuterPath(offset & configuration.size!);

    canvas.save();
    canvas.drawPath(
      path,
      Paint()
        ..color = rekt?.color ?? Color.fromRGBO(0, 0, 0, depth / 3)
        ..blendMode = BlendMode.overlay,
    );
    if (rekt?.color case final color?) {
      final opacity = color.opacity;
      canvas.drawPath(
        path,
        Paint()..color = color.withOpacity(opacity * opacity),
      );
    }
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
