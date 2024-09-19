import 'package:flutter/widgets.dart';

abstract class AnimatedRenderObjectWidget extends SingleChildRenderObjectWidget {
  const AnimatedRenderObjectWidget({super.key, super.child});

  Listenable get listenable;

  @override
  AnimatedRenderObjectElement createElement() => AnimatedRenderObjectElement(this);
}

class AnimatedRenderObjectElement extends SingleChildRenderObjectElement {
  AnimatedRenderObjectElement(AnimatedRenderObjectWidget super.widget);

  @override
  AnimatedRenderObjectWidget get widget => super.widget as AnimatedRenderObjectWidget;

  // ignore: invalid_use_of_protected_member
  void listener() => widget.updateRenderObject(this, renderObject);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    widget.listenable.addListener(listener);
  }

  @override
  void unmount() {
    widget.listenable.removeListener(listener);
    super.unmount();
  }
}
