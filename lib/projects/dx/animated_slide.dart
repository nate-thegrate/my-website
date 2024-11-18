import 'package:nate_thegrate/the_good_stuff.dart';

class AnimatedSlide extends AnimatedValue<Offset> {
  const AnimatedSlide({
    super.key,
    required Offset offset,
    Offset? initialOffset,
    required super.duration,
    super.curve,
    super.onEnd,
    super.child,
  }) : super(value: offset, initialValue: initialOffset, lerp: Offset.lerp);

  @override
  Widget build(BuildContext context, Animation<Offset> animation) {
    return SlideTransition(slideAnimation: animation, child: child);
  }
}

class SlideTransition extends SingleChildRenderObjectWidget {
  const SlideTransition({
    super.key,
    required this.slideAnimation,
    this.transformHitTests = true,
    super.child,
  });

  final ValueListenable<Offset> slideAnimation;

  final bool transformHitTests;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnimatedSlide(
      slideAnimation: slideAnimation,
      transformHitTests: transformHitTests,
    );
  }
}

class RenderAnimatedSlide extends RenderFractionalTranslation {
  RenderAnimatedSlide({required this.slideAnimation, super.transformHitTests})
    : super(translation: slideAnimation.value) {
    slideAnimation.addListener(listener);
  }

  final ValueListenable<Offset> slideAnimation;

  void listener() {
    translation = slideAnimation.value;
  }

  @override
  void dispose() {
    slideAnimation.removeListener(listener);
    super.dispose();
  }
}
