import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class SourceCard extends StatelessWidget {
  const SourceCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (RecursionCount.of(context) > 0) return const _CardRecursion();

    return const Stached(direction: AxisDirection.right, child: _SourceCard());
  }
}

class _SourceCard extends ConsumerStatefulWidget {
  const _SourceCard();

  @override
  ConsumerState<_SourceCard> createState() => _SourceCardState();
}

class ColorAnimation extends ValueAnimation<Color> {
  ColorAnimation({
    required super.vsync,
    required super.initialValue,
    required super.duration,
  }) : super(lerp: Color.lerp);

  static const grey = Color(0xffe0e0e0);
  static const offWhite = Color(0xfff0f0f0);
}

final _sourceStatesProvider = WidgetStatesProvider(WidgetStates.new);
final _active = WidgetState.hovered | WidgetState.selected;

final colorProvider = Provider((Ref ref) {
  final Set<WidgetState> states = ref.watch(_sourceStatesProvider)!;

  return _active.isSatisfiedBy(states) ? ColorAnimation.offWhite : ColorAnimation.grey;
});

class _SourceCardState extends ConsumerState<_SourceCard> with SingleTickerProviderStateMixin {
  double scale = 1.0;

  late final colorAnimation = ColorAnimation(
    vsync: this,
    initialValue: ColorAnimation.grey,
    duration: Durations.short2,
  );
  late final states = ref.read(_sourceStatesProvider.notifier);
  late final ProviderSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = ref.listenManual(
      colorProvider,
      (_, color) => colorAnimation.value = color,
    );
  }

  @override
  void dispose() {
    subscription.close();
    colorAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => states.add(WidgetState.hovered),
      onExit: (event) => states.remove(WidgetState.hovered),
      child: TapRegion(
        onTapInside: (event) async {
          Source.approach();
          states.add(WidgetState.selected);
        },
        behavior: HitTestBehavior.opaque,
        child: const _CardRecursion(),
      ),
    );
  }
}

class RecursionCount extends StatelessWidget {
  const RecursionCount({super.key});

  static int of(BuildContext context) {
    final key = context.findAncestorWidgetOfExactType<_RecursionCount>()?.key as ValueKey<int>?;
    return key != null ? key.value + 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final recursions = RecursionCount.of(context);
    if (recursions > 6) {
      if (hasAncestor<DxTransition>(context)) {
        return const SizedBox.shrink();
      }
      return const Source.gateway();
    }

    return SizedBox.fromSize(
      size: MediaQuery.sizeOf(context),
      child: _RecursionCount(
        key: ValueKey(recursions),
        child: const ProjectGrid(),
      ),
    );
  }
}

class _RecursionCount extends KeyedSubtree {
  const _RecursionCount({required ValueKey<int> super.key, required super.child});
}

class _CardRecursion extends HookWidget {
  const _CardRecursion();

  @override
  Widget build(BuildContext context) {
    final color = useAnimationFrom<_SourceCardState, Color>((s) => s.colorAnimation);
    const child = Center(
      child: IgnorePointer(
        child: FittedBox(
          fit: BoxFit.cover,
          child: _ScreenSizedBox(
            child: RecursionCount(),
          ),
        ),
      ),
    );

    return AnimatedValue.transition(
      useValueListenable(TheApproach.approaching) ? 0.0 : 5.0,
      lerp: lerpDouble,
      duration: Durations.medium1,
      builder: (context, elevation) => _InnerSourceCard(elevation, color, child: child),
    );
  }
}

class _ScreenSizedBox extends StatelessWidget {
  const _ScreenSizedBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(size: MediaQuery.sizeOf(context), child: child);
  }
}

class _InnerSourceCard extends SingleChildRenderObjectWidget with RenderListenable {
  const _InnerSourceCard(
    this.elevation,
    this.color, {
    super.child,
  });

  final ValueListenable<double> elevation;
  final ValueListenable<Color> color;

  @override
  Listenable get listenable => Listenable.merge({elevation, color});

  @override
  EtherealCard createRenderObject(BuildContext context) {
    return EtherealCard(elevation: elevation.value, color: color.value);
  }

  @override
  void updateRenderObject(BuildContext context, EtherealCard renderObject) {
    renderObject
      ..elevation = elevation.value
      ..color = color.value;
  }
}
