import 'dart:ui' as ui;
import 'package:nate_thegrate/the_good_stuff.dart';

typedef AnimationBuilder<T> = Widget Function(BuildContext context, Animation<T> animation);

/// A widget that animates based on changes to its [value].
///
/// This class uses a [duration], [curve], and [lerp] callback to determine
/// its transition from one value to another.
///
/// The widget will immediately animate from its [initialValue] to the [value],
/// if an [initialValue] is specified. Otherwise, the widget is "implicitly"
/// animated: it performs an animation when its [value] changes.
///
/// {@tool snippet}
/// This example shows how to build a widget that animates its size based on
/// an explicit `size` parameter, instead of adjusting based on its child as
/// [AnimatedSize] does.
///
/// ```dart
/// class MyAnimatedSize extends AnimatedValue<Size> {
///   const MyAnimatedSize({
///     super.key,
///     required Size size,
///     required super.duration,
///     super.curve,
///     super.initialValue,
///     super.child,
///   }) : super(size, lerp: Size.lerp);
///
///   @override
///   Widget build(BuildContext context, Size value) {
///     return SizedBox.fromSize(size: value, child: child);
///   }
/// }
/// ```
/// {@end-tool}
///
/// [AnimatedContainer], a subclass of [AnimatedValue], uses a [Record] as its
/// [value] type: this allows it to [lerp] multiple properties at once.
///
/// Other subtypes of `AnimatedValue` include:
///
///  * [AnimatedAlign], which is an implicitly animated version of [Align].
///  * [AnimatedDefaultTextStyle], which is an implicitly animated version of
///    [DefaultTextStyle].
///  * [AnimatedScale], which is an implicitly animated version of [Transform.scale].
///  * [AnimatedRotation], which is an implicitly animated version of [Transform.rotate].
///  * [AnimatedSlide], which implicitly animates the position of a widget relative to its normal position.
///  * [AnimatedOpacity], which is an implicitly animated version of [Opacity].
///  * [AnimatedPadding], which is an implicitly animated version of [Padding].
///  * [AnimatedPhysicalModel], which is an implicitly animated version of
///    [PhysicalModel].
///  * [AnimatedPositioned], which is an implicitly animated version of
///    [Positioned].
///  * [AnimatedPositionedDirectional], which is an implicitly animated version
///    of [PositionedDirectional].
///  * [AnimatedTheme], which is an implicitly animated version of [Theme].
///
/// See also:
///
///  * [ImplicitlyAnimatedWidget], which was used to create implicit animations
///    before [Record] types were supported in Dart.
///  * [TweenAnimationBuilder], which is similar to [AnimatedValue.builder],
///    but uses a [Tween] rather than a [LerpCallback] for evaluation.
///  * [AnimatedCrossFade], which cross-fades between two given children and
///    animates itself between their sizes.
///  * [AnimatedSize], which automatically transitions its size over a given
///    duration.
///  * [AnimatedSwitcher], which fades from one widget to another.
class AnimatedValue<T extends Object> extends StatefulWidget {
  const AnimatedValue({
    super.key,
    required this.value,
    this.initialValue,
    required this.duration,
    this.curve = Curves.linear,
    required this.lerp,
    this.onEnd,
    this.child,
  });

  factory AnimatedValue.transition(
    T value, {
    Key? key,
    T? initial,
    required Duration duration,
    Curve curve,
    LerpCallback<T>? lerp,
    VoidCallback? onEnd,
    required AnimationBuilder<T> builder,
  }) = _AnimatedValueTransition<T>;

  /// Builds an animation using the provided [ValueWidgetBuilder].
  ///
  /// See also:
  ///
  ///  * [TweenAnimationBuilder], which does the same,
  ///    using a [Tween] rather than a [LerpCallback].
  factory AnimatedValue.builder(
    T value, {
    Key? key,
    T? initial,
    required Duration duration,
    Curve curve,
    required ValueWidgetBuilder<T> builder,
    LerpCallback<T>? lerp,
    VoidCallback? onEnd,
    Widget? child,
  }) = _AnimatedValueBuilder<T>;

  /// The target value of the animation.
  ///
  /// When this value changes, this widget's associated [ValueAnimation]
  /// will smoothly transition to its new value.
  final T value;

  /// If this is non-null, the widget will immediately start animating from this
  /// value toward the target [value] when it is first built.
  final T? initialValue;

  /// The duration over which to animate changes to the [value].
  final Duration duration;

  /// The curve to apply when the widget animates.
  ///
  /// For example, using [Curves.ease] may improve the animation's visual appeal
  /// by mitigating the linear animation's abrupt stop.
  final Curve curve;

  /// A function that defines the type [T]'s linear interpolation
  /// from one [value] to another.
  ///
  /// {@macro flutter.animation.LerpCallback}
  ///
  /// If the [LerpCallback] is defined as a global function or `static` method,
  /// it can be used in a `const` constructor!
  final LerpCallback<T> lerp;

  /// Called each time the animation completes.
  ///
  /// This can be useful to trigger additional actions (e.g. another animation)
  /// at the end of the current animation.
  final VoidCallback? onEnd;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  Widget build(BuildContext context, Animation<T> animation) => child!;

  /// It's possible to use custom [RenderBox] and [RenderObjectWidget] classes
  /// in place of existing Flutter widgets.
  /// Doing so can make implementation & debugging much more difficult
  /// but can sometimes improve the app's performance.
  ///
  /// Similarly, obtaining this widget's animation
  /// (via [BuildContext.findAncestorStateOfType]) is not explicitly recommended,
  /// but [AnimatedValueState] is public in order to make it possible.
  @override
  AnimatedValueState<T> createState() => AnimatedValueState<T>();
}

class AnimatedValueState<T extends Object> extends State<AnimatedValue<T>>
    with SingleTickerProviderStateMixin {
  late final ValueAnimation<T> animation = ValueAnimation<T>(
    vsync: this,
    initialValue: widget.initialValue ?? widget.value,
    duration: widget.duration,
    curve: widget.curve,
    lerp: widget.lerp,
  );

  void _statusUpdate(AnimationStatus status) {
    if (status.isCompleted) {
      widget.onEnd?.call();
    }
  }

  @protected
  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null) {
      animation.animateTo(widget.value);
    }
    animation.addStatusListener(_statusUpdate);
  }

  @protected
  @override
  void didUpdateWidget(covariant AnimatedValue<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      animation.animateTo(widget.value, duration: widget.duration, curve: widget.curve);
    } else {
      animation
        ..duration = widget.duration
        ..curve = widget.curve;
    }
  }

  @protected
  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @protected
  @override
  Widget build(BuildContext context) => widget.build(context, animation);
}

class _AnimatedValueBuilder<T extends Object> extends AnimatedValue<T> {
  _AnimatedValueBuilder(
    T value, {
    super.key,
    T? initial,
    required super.duration,
    super.curve,
    LerpCallback<T>? lerp,
    super.onEnd,
    required this.builder,
    super.child,
  }) : super(
         value: value,
         initialValue: initial,
         lerp: lerp ?? ValueAnimation.lerpCallbackOfExactType<T>(),
       );

  final ValueWidgetBuilder<T> builder;

  @override
  AnimatedValueState<T> createState() => _AnimatedValueBuilderState<T>();
}

class _AnimatedValueTransition<T extends Object> extends AnimatedValue<T> {
  _AnimatedValueTransition(
    T value, {
    super.key,
    T? initial,
    required super.duration,
    super.curve,
    LerpCallback<T>? lerp,
    super.onEnd,
    required this.builder,
  }) : super(
         value: value,
         initialValue: initial,
         lerp: lerp ?? ValueAnimation.lerpCallbackOfExactType<T>(),
       );

  final AnimationBuilder<T> builder;

  @override
  Widget build(BuildContext context, Animation<T> animation) {
    return builder(context, animation);
  }
}

/// An implicitly animated widget whose [value] transitions between
/// `0.0` (false) and `1.0` (true).
///
/// {@tool snippet}
/// [AnimatedToggle] is an `extension type` that wraps [AnimatedValue].
/// For more precise control over the speed & curve of the toggling animation,
/// consider using a [StatefulWidget] with a [ToggleAnimation] as part
/// of its [State].
///
/// ```dart
/// class MyToggle extends StatefulWidget {
///   const MyToggle({super.key});
///
///   @override
///   State<MyToggle> createState() => _MyToggleState();
/// }
///
/// class _MyToggleState extends State<MyToggle> with SingleTickerProviderStateMixin {
///   late final ToggleAnimation _toggleAnimation = ToggleAnimation(
///     vsync: this,
///     duration: Durations.medium1,
///   );
///
///   late final CurvedAnimation animation = CurvedAnimation(
///     parent: _toggleAnimation,
///     curve: Curves.ease,
///     reverseCurve: Curves.easeInOutSine,
///   );
///
///   // ...
/// }
/// ```
/// {@end-tool}
extension type AnimatedToggle(AnimatedValue<double> _widget) implements AnimatedValue<double> {
  AnimatedToggle.builder(
    // ignore: avoid_positional_boolean_parameters, frick that
    bool forward, {
    Key? key,
    bool animateOnCreate = false,
    required Duration duration,
    Curve curve = Curves.linear,
    required ValueWidgetBuilder<double> builder,
    VoidCallback? onEnd,
    Widget? child,
  }) : _widget = AnimatedValue<double>.builder(
         forward ? 1.0 : 0.0,
         key: key,
         initial: (forward != animateOnCreate) ? 1.0 : 0.0,
         duration: duration,
         curve: curve,
         builder: builder,
         onEnd: onEnd,
         lerp: ui.lerpDouble,
         child: child,
       );

  AnimatedToggle.transition(
    // ignore: avoid_positional_boolean_parameters, frick that
    bool forward, {
    Key? key,
    bool animateOnCreate = false,
    required Duration duration,
    Curve curve = Curves.linear,
    required AnimationBuilder<double> builder,
    VoidCallback? onEnd,
  }) : _widget = AnimatedValue<double>.transition(
         forward ? 1.0 : 0.0,
         key: key,
         initial: (forward != animateOnCreate) ? 1.0 : 0.0,
         duration: duration,
         curve: curve,
         builder: builder,
         onEnd: onEnd,
         lerp: ui.lerpDouble,
       );
}

/// Configures the [animation] to call [Element.markNeedsBuild]
/// each time its value changes.
class _AnimatedValueBuilderState<T extends Object> extends AnimatedValueState<T> {
  @override
  void initState() {
    super.initState();
    animation.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final ValueWidgetBuilder<T> builder = (widget as _AnimatedValueBuilder<T>).builder;
    return builder(context, animation.value, widget.child);
  }
}
