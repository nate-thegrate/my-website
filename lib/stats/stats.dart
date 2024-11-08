import 'dart:math' as math;

import 'package:nate_thegrate/the_good_stuff.dart';

export 'pr_data/pr_data.dart';

extension type const Stats._(TopBar _) implements TopBar {
  const Stats() : _ = const TopBar(body: _Stats());

  static Page<void> pageBuilder(BuildContext context, GoRouterState state) {
    final String? param = state.pathParameters['refactor'];

    return NoTransitionPage(
      child: Refactoring(
        refactor: param != null && param.endsWith('true'),
        child: const Stats(),
      ),
    );
  }

  static const background = Color(0xfff3f8f8);
  static const insets = 14.0;
  static const maxWidth = 720.0;
  static const itemExtent = 36.0;
}

class Refactoring extends InheritedWidget {
  const Refactoring({required this.refactor, required super.child})
      : super(key: const GlobalObjectKey(Refactoring));

  final bool refactor;

  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Refactoring>()!.refactor;
  }

  @override
  bool updateShouldNotify(Refactoring oldWidget) => refactor != oldWidget.refactor;
}

class _Stats extends StatefulWidget {
  const _Stats();

  @override
  State<_Stats> createState() => _StatsState();
}

class _StatsState extends State<_Stats> {
  bool floatingFooter = true;
  double targetExtent = double.infinity;
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      final bool shouldFloat = controller.offset < targetExtent;
      if (shouldFloat != floatingFooter) {
        setState(() => floatingFooter = shouldFloat);
      }
    });
    Future.delayed(Durations.long2, () => Route.current = TopBar.focused = Route.stats);
    postFrameCallback(() => HomePageElement.instance.opacity.value = 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final bool refactoring = Refactoring.of(context);
    final padding = EdgeInsets.symmetric(
      horizontal: math.max(
        Stats.insets,
        (MediaQuery.sizeOf(context).width - Stats.maxWidth) / 2,
      ),
    );
    final slivers = <Widget>[
      SliverMainAxisGroup(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _TableHeader(refactoring: refactoring),
          ),
          SliverFixedExtentList.list(
            itemExtent: Stats.itemExtent,
            children: refactoring ? refactorPRs : flutterPRs,
          ),
        ],
      ),
      SliverLayoutBuilder(builder: (context, constraints) {
        final SliverConstraints(
          :double precedingScrollExtent,
          :double viewportMainAxisExtent,
          :double remainingPaintExtent,
        ) = constraints;

        targetExtent = precedingScrollExtent + 36.0 - viewportMainAxisExtent;

        Widget? total;
        if (remainingPaintExtent >= 36.0) {
          total = PullRequest.total(onlyRefactor: refactoring);
        }
        return SliverToBoxAdapter(child: SizedBox(height: 36.0, child: total));
      }),
      const SliverToBoxAdapter(
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: PullRequest.borderColor),
              ),
            ),
            child: Center(child: _RefactorButton()),
          ),
        ),
      ),
    ];

    return ColoredBox(
      color: Stats.background,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomScrollView(
            controller: controller,
            physics: const StickToBottom(),
            slivers: [
              for (final sliver in slivers) SliverPadding(padding: padding, sliver: sliver),
            ],
          ),
          if (floatingFooter)
            Padding(
              padding: padding,
              child: SizedBox(
                height: 36.0,
                child: ColoredBox(
                  color: const Color(0xe0f8ffff),
                  child: PullRequest.total(onlyRefactor: refactoring),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StickToBottom extends ClampingScrollPhysics {
  const StickToBottom();

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    if (newPosition.extentTotal != oldPosition.extentTotal) {
      return newPosition.maxScrollExtent;
    }
    return super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );
  }

  @override
  StickToBottom applyTo(ScrollPhysics? ancestor) => this;

  @override
  StickToBottom buildParent(ScrollPhysics? ancestor) => this;
}

class _TableHeader extends SliverPersistentHeaderDelegate {
  const _TableHeader({required this.refactoring});

  final bool refactoring;

  @override
  double get minExtent => 36.0;
  @override
  double get maxExtent => 36.0;

  @override
  bool shouldRebuild(_TableHeader oldDelegate) => refactoring != oldDelegate.refactoring;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    const diffs = [
      Diffs('+', color: RightColumn.green),
      Diffs('–', color: RightColumn.red),
      Diffs('Δ', color: Colors.black),
    ];
    final dateBox = ColoredBox(
      color: shrinkOffset == 0 ? Colors.white54 : Colors.transparent,
      child: DefaultTextStyle(
        style: TextStyle(
          color: RightColumn.dateColor(darker: shrinkOffset > 0),
          fontWeight: FontWeight.w600,
        ),
        child: const SizedBox(
          width: RightColumn.dateWidth,
          child: Center(
            child: Text('date'),
          ),
        ),
      ),
    );

    final header = DefaultTextStyle(
      style: const TextStyle(fontWeight: FontWeight.w600),
      child: Row(
        key: const GlobalObjectKey('header'),
        children: [
          Expanded(
            child: Center(
              child: Text(
                refactoring
                    ? 'Refactoring (lines added/removed)'
                    : 'Flutter framework contributions',
                style: const TextStyle(color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (refactoring) ...diffs else dateBox,
        ],
      ),
    );

    if (shrinkOffset == 0) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: PullRequest.border),
        ),
        child: header,
      );
    }
    return ColoredBox(color: const Color(0xe0f8ffff), child: header);
  }
}

class _RefactorButton extends StatelessWidget {
  const _RefactorButton();

  @override
  Widget build(BuildContext context) {
    final bool onlyRefactorPRs = Refactoring.of(context);

    const WidgetStatePropertyAll<EdgeInsets> padding =
        WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24, vertical: 18));
    const boringStyle = ButtonStyle(
      side: WidgetStatePropertyAll(
        BorderSide(width: 2, color: Color(0xff80a0a0)),
      ),
      backgroundColor: WidgetStateMapper<Color?>({
        WidgetState.selected: Color(0xffc0e0e0),
      }),
      foregroundColor: WidgetStatePropertyAll(Color(0xff406060)),
      padding: padding,
    );
    const refactorStyle = ButtonStyle(
      side: WidgetStatePropertyAll(
        BorderSide(width: 2, color: Color(0xff80ffff)),
      ),
      backgroundColor: WidgetStateMapper<Color?>({
        WidgetState.selected: Color(0xff80ffff),
      }),
      foregroundColor: WidgetStatePropertyAll(Colors.black),
      overlayColor: WidgetStateMapper({
        WidgetState.pressed: Color(0x4000c0c0),
        WidgetState.hovered: Color(0x2000ffff),
        WidgetState.any: Color(0x2000c0c0),
      }),
      padding: padding,
    );

    return SegmentedButton<bool>(
      style: onlyRefactorPRs ? refactorStyle : boringStyle,
      segments: const [
        ButtonSegment(value: false, label: Text('all')),
        ButtonSegment(value: true, label: Text('refactor')),
      ],
      selected: {onlyRefactorPRs},
      onSelectionChanged: (selected) {
        Route.go(selected.single ? Route.refactorStats : Route.stats);
      },
      showSelectedIcon: false,
    );
  }
}
