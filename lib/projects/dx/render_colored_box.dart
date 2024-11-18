import 'package:nate_thegrate/the_good_stuff.dart';

/// The [RenderObject] created by [ColoredBox], copy-pasted and made public :)
class RenderColoredBox extends RenderProxyBoxWithHitTestBehavior {
  RenderColoredBox({required Color color})
      : _color = color,
        super(behavior: HitTestBehavior.opaque);

  /// The fill color for this render object.
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) {
      return;
    }
    _color = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size > Size.zero) {
      context.canvas.drawRect(offset & size, Paint()..color = color);
    }
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
