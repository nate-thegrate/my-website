import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

abstract class SliverSticky extends RenderObjectWidget {
  const SliverSticky({super.key});

  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent);

  double get extent;

  bool shouldRebuild(covariant SliverSticky oldWidget);

  @override
  RenderObjectElement createElement() => _SliverPersistentHeaderElement(this);

  @override
  RenderSliver createRenderObject(BuildContext context) => _RenderSliverSticky();
}

class _SliverPersistentHeaderElement extends RenderObjectElement {
  _SliverPersistentHeaderElement(SliverSticky super.widget);

  @override
  _RenderSliverSticky get renderObject => super.renderObject as _RenderSliverSticky;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    renderObject._element = this;
  }

  @override
  void unmount() {
    renderObject._element = null;
    super.unmount();
  }

  @override
  void update(SliverSticky newWidget) {
    final SliverSticky oldWidget = widget as SliverSticky;
    super.update(newWidget);
    if (newWidget != oldWidget && newWidget.shouldRebuild(oldWidget)) {
      renderObject.markNeedsLayout();
    }
  }

  @override
  void performRebuild() {
    super.performRebuild();
    renderObject.markNeedsLayout();
  }

  Element? child;

  void _build(double shrinkOffset, bool overlapsContent) {
    owner!.buildScope(this, () {
      child = updateChild(
        child,
        (widget as SliverSticky).build(this, shrinkOffset, overlapsContent),
        null,
      );
    });
  }

  @override
  void forgetChild(Element child) {
    assert(child == this.child);
    this.child = null;
    super.forgetChild(child);
  }

  @override
  void insertRenderObjectChild(RenderBox child, Object? slot) {
    renderObject.child = child;
  }

  @override
  void moveRenderObjectChild(RenderObject child, Object? oldSlot, Object? newSlot) {}

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    renderObject.child = null;
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (child != null) {
      visitor(child!);
    }
  }
}

class _RenderSliverSticky extends RenderSliver with RenderObjectWithChildMixin<RenderBox> {
  _RenderSliverSticky({RenderBox? child}) {
    this.child = child;
  }

  _SliverPersistentHeaderElement? _element;

  double get extent => (_element!.widget as SliverSticky).extent;

  void updateChild(double shrinkOffset, bool overlapsContent) {
    assert(_element != null);
    _element!._build(shrinkOffset, overlapsContent);
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final extent = this.extent;
    final bool overlapsContent = constraints.overlap > 0.0;
    layoutChild(constraints.scrollOffset, extent, overlapsContent: overlapsContent);
    final double effectiveRemainingPaintExtent =
        math.max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent =
        clampDouble(extent - constraints.scrollOffset, 0.0, effectiveRemainingPaintExtent);
    final double stretchOffset = stretchConfiguration != null ? constraints.overlap.abs() : 0.0;
    geometry = SliverGeometry(
      scrollExtent: extent,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent, effectiveRemainingPaintExtent),
      layoutExtent: layoutExtent,
      maxPaintExtent: extent + stretchOffset,
      maxScrollObstructionExtent: extent,
      cacheExtent: layoutExtent > 0.0 ? -constraints.cacheOrigin + layoutExtent : layoutExtent,
      hasVisualOverflow: true, // Conservatively say we do have overflow to avoid complexity.
    );
  }

  @override
  double childMainAxisPosition(RenderBox child) => 0.0;

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    final Rect? localBounds = descendant != null
        ? MatrixUtils.transformRect(
            descendant.getTransformTo(this), rect ?? descendant.paintBounds)
        : rect;

    final Rect? newRect = switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      AxisDirection.up => _trim(localBounds, bottom: childExtent),
      AxisDirection.left => _trim(localBounds, right: childExtent),
      AxisDirection.right => _trim(localBounds, left: 0),
      AxisDirection.down => _trim(localBounds, top: 0),
    };

    super.showOnScreen(
      descendant: this,
      rect: newRect,
      duration: duration,
      curve: curve,
    );
  }

  @protected
  double get childExtent {
    if (child == null) {
      return 0.0;
    }
    assert(child!.hasSize);
    return switch (constraints.axis) {
      Axis.vertical => child!.size.height,
      Axis.horizontal => child!.size.width,
    };
  }

  bool _needsUpdateChild = true;
  double _lastShrinkOffset = 0.0;
  bool _lastOverlapsContent = false;

  OverScrollHeaderStretchConfiguration? stretchConfiguration;

  late double _lastStretchOffset;

  @override
  void markNeedsLayout() {
    // This is automatically called whenever the child's intrinsic dimensions
    // change, at which point we should remeasure them during the next layout.
    _needsUpdateChild = true;
    super.markNeedsLayout();
  }

  @protected
  void layoutChild(double scrollOffset, double maxExtent, {bool overlapsContent = false}) {
    final double shrinkOffset = math.min(scrollOffset, maxExtent);
    if (_needsUpdateChild ||
        _lastShrinkOffset != shrinkOffset ||
        _lastOverlapsContent != overlapsContent) {
      invokeLayoutCallback<SliverConstraints>((constraints) {
        assert(constraints == this.constraints);
        updateChild(shrinkOffset, overlapsContent);
      });
      _lastShrinkOffset = shrinkOffset;
      _lastOverlapsContent = overlapsContent;
      _needsUpdateChild = false;
    }
    double stretchOffset = 0.0;
    if (stretchConfiguration != null && constraints.scrollOffset == 0.0) {
      stretchOffset += constraints.overlap.abs();
    }

    child?.layout(
      constraints.asBoxConstraints(
        maxExtent: math.max(extent, maxExtent - shrinkOffset) + stretchOffset,
      ),
      parentUsesSize: true,
    );

    if (stretchConfiguration != null &&
        stretchConfiguration!.onStretchTrigger != null &&
        stretchOffset >= stretchConfiguration!.stretchTriggerOffset &&
        _lastStretchOffset <= stretchConfiguration!.stretchTriggerOffset) {
      stretchConfiguration!.onStretchTrigger!();
    }
    _lastStretchOffset = stretchOffset;
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    assert(geometry!.hitTestExtent > 0.0);
    if (child != null) {
      return hitTestBoxChild(BoxHitTestResult.wrap(result), child!,
          mainAxisPosition: mainAxisPosition, crossAxisPosition: crossAxisPosition);
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child == this.child);
    applyPaintTransformForBoxChild(child as RenderBox, transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      offset += switch (applyGrowthDirectionToAxisDirection(
          constraints.axisDirection, constraints.growthDirection)) {
        AxisDirection.up =>
          Offset(0.0, geometry!.paintExtent - childMainAxisPosition(child!) - childExtent),
        AxisDirection.left =>
          Offset(geometry!.paintExtent - childMainAxisPosition(child!) - childExtent, 0.0),
        AxisDirection.right => Offset(childMainAxisPosition(child!), 0.0),
        AxisDirection.down => Offset(0.0, childMainAxisPosition(child!)),
      };
      context.paintChild(child!, offset);
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.addTagForChildren(RenderViewport.excludeFromScrolling);
  }

  bool _getRightWayUp(SliverConstraints constraints) {
    final bool reversed = axisDirectionIsReversed(constraints.axisDirection);
    return switch (constraints.growthDirection) {
      GrowthDirection.forward => !reversed,
      GrowthDirection.reverse => reversed,
    };
  }

  @protected
  bool hitTestBoxChild(
    BoxHitTestResult result,
    RenderBox child, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    final bool rightWayUp = _getRightWayUp(constraints);
    double delta = childMainAxisPosition(child);
    final double crossAxisDelta = childCrossAxisPosition(child);
    double absolutePosition = mainAxisPosition - delta;
    final double absoluteCrossAxisPosition = crossAxisPosition - crossAxisDelta;
    Offset paintOffset, transformedPosition;
    switch (constraints.axis) {
      case Axis.horizontal:
        if (!rightWayUp) {
          absolutePosition = child.size.width - absolutePosition;
          delta = geometry!.paintExtent - child.size.width - delta;
        }
        paintOffset = Offset(delta, crossAxisDelta);
        transformedPosition = Offset(absolutePosition, absoluteCrossAxisPosition);
      case Axis.vertical:
        if (!rightWayUp) {
          absolutePosition = child.size.height - absolutePosition;
          delta = geometry!.paintExtent - child.size.height - delta;
        }
        paintOffset = Offset(crossAxisDelta, delta);
        transformedPosition = Offset(absoluteCrossAxisPosition, absolutePosition);
    }
    return result.addWithOutOfBandPosition(
      paintOffset: paintOffset,
      hitTest: (result) {
        return child.hitTest(result, position: transformedPosition);
      },
    );
  }

  @protected
  void applyPaintTransformForBoxChild(RenderBox child, Matrix4 transform) {
    final bool rightWayUp = _getRightWayUp(constraints);
    double delta = childMainAxisPosition(child);
    final double crossAxisDelta = childCrossAxisPosition(child);
    switch (constraints.axis) {
      case Axis.horizontal:
        if (!rightWayUp) {
          delta = geometry!.paintExtent - child.size.width - delta;
        }
        transform.translate(delta, crossAxisDelta);
      case Axis.vertical:
        if (!rightWayUp) {
          delta = geometry!.paintExtent - child.size.height - delta;
        }
        transform.translate(crossAxisDelta, delta);
    }
  }
}

Rect? _trim(
  Rect? original, {
  double top = -double.infinity,
  double right = double.infinity,
  double bottom = double.infinity,
  double left = -double.infinity,
}) {
  return original?.intersect(Rect.fromLTRB(left, top, right, bottom));
}
