// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/rendering.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

class SliverPinnedPersistentHeader extends RenderObjectWidget {
  const SliverPinnedPersistentHeader({
    super.key,
    required this.delegate,
  });

  final SliverPersistentHeaderDelegate delegate;

  @override
  _SliverPersistentHeaderElement createElement() => _SliverPersistentHeaderElement(this);

  @override
  _RenderSliverPinnedPersistentHeaderForWidgets createRenderObject(BuildContext context) {
    return _RenderSliverPinnedPersistentHeaderForWidgets(
      stretchConfiguration: delegate.stretchConfiguration,
      showOnScreenConfiguration: delegate.showOnScreenConfiguration,
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      covariant _RenderSliverPinnedPersistentHeaderForWidgets renderObject) {
    renderObject
      ..stretchConfiguration = delegate.stretchConfiguration
      ..showOnScreenConfiguration = delegate.showOnScreenConfiguration;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<SliverPersistentHeaderDelegate>(
        'delegate',
        delegate,
      ),
    );
  }
}

class _SliverPersistentHeaderElement extends RenderObjectElement {
  _SliverPersistentHeaderElement(SliverPinnedPersistentHeader super.widget);

  @override
  _RenderSliverPinnedPersistentHeaderForWidgets get renderObject =>
      super.renderObject as _RenderSliverPinnedPersistentHeaderForWidgets;

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
  void update(SliverPinnedPersistentHeader newWidget) {
    final SliverPinnedPersistentHeader oldWidget = widget as SliverPinnedPersistentHeader;
    super.update(newWidget);
    final SliverPersistentHeaderDelegate newDelegate = newWidget.delegate;
    final SliverPersistentHeaderDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) {
      renderObject.triggerRebuild();
    }
  }

  @override
  void performRebuild() {
    super.performRebuild();
    renderObject.triggerRebuild();
  }

  Element? child;

  void _build(double shrinkOffset, bool overlapsContent) {
    owner!.buildScope(this, () {
      final SliverPinnedPersistentHeader sliverPersistentHeaderRenderObjectWidget =
          widget as SliverPinnedPersistentHeader;
      child = updateChild(
        child,
        sliverPersistentHeaderRenderObjectWidget.delegate
            .build(this, shrinkOffset, overlapsContent),
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
  void insertRenderObjectChild(covariant RenderBox child, Object? slot) {
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
  }

  @override
  void moveRenderObjectChild(covariant RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, Object? slot) {
    renderObject.child = null;
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (child != null) {
      visitor(child!);
    }
  }
}

class _RenderSliverPinnedPersistentHeaderForWidgets extends RenderSliverPinnedPersistentHeader {
  _RenderSliverPinnedPersistentHeaderForWidgets({
    super.stretchConfiguration,
    super.showOnScreenConfiguration,
  });

  _SliverPersistentHeaderElement? _element;

  @override
  double get minExtent => (_element!.widget as SliverPinnedPersistentHeader).delegate.minExtent;

  @override
  double get maxExtent => (_element!.widget as SliverPinnedPersistentHeader).delegate.maxExtent;

  @override
  void updateChild(double shrinkOffset, bool overlapsContent) {
    assert(_element != null);
    _element!._build(shrinkOffset, overlapsContent);
  }

  @protected
  void triggerRebuild() {
    markNeedsLayout();
  }
}

class _FloatingHeader extends StatefulWidget {
  const _FloatingHeader({required this.child});

  final Widget child;

  @override
  _FloatingHeaderState createState() => _FloatingHeaderState();
}

// A wrapper for the widget created by _SliverPersistentHeaderElement that
// starts and stops the floating app bar's snap-into-view or snap-out-of-view
// animation. It also informs the float when pointer scrolling by updating the
// last known ScrollDirection when scrolling began.
class _FloatingHeaderState extends State<_FloatingHeader> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_position != null) {
      _position!.isScrollingNotifier.removeListener(_isScrollingListener);
    }
    _position = Scrollable.maybeOf(context)?.position;
    if (_position != null) {
      _position!.isScrollingNotifier.addListener(_isScrollingListener);
    }
  }

  @override
  void dispose() {
    if (_position != null) {
      _position!.isScrollingNotifier.removeListener(_isScrollingListener);
    }
    super.dispose();
  }

  RenderSliverFloatingPersistentHeader? _headerRenderer() {
    return context.findAncestorRenderObjectOfType<RenderSliverFloatingPersistentHeader>();
  }

  void _isScrollingListener() {
    assert(_position != null);

    // When a scroll stops, then maybe snap the app bar into view.
    // Similarly, when a scroll starts, then maybe stop the snap animation.
    // Update the scrolling direction as well for pointer scrolling updates.
    final RenderSliverFloatingPersistentHeader? header = _headerRenderer();
    if (_position!.isScrollingNotifier.value) {
      header?.updateScrollStartDirection(_position!.userScrollDirection);
      // Only SliverAppBars support snapping, headers will not snap.
      header?.maybeStopSnapAnimation(_position!.userScrollDirection);
    } else {
      // Only SliverAppBars support snapping, headers will not snap.
      header?.maybeStartSnapAnimation(_position!.userScrollDirection);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
