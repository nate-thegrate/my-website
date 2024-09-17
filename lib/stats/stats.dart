import 'dart:math' as math;

import 'package:nate_thegrate/the_good_stuff.dart';

export 'pr_data/pr_data.dart';

class Stats extends TopBar {
  const Stats({super.key}) : super(body: const TheDeets());

  static Page<void> pageBuilder(BuildContext context, GoRouterState state) {
    return NoTransitionPage(
      child: Refactoring(
        refactor: state.pathParameters['refactor'] == 'true',
        child: const Stats(),
      ),
    );
  }

  static const insets = 14.0;
  static const maxWidth = 720.0;
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

class TheDeets extends StatefulWidget {
  const TheDeets({super.key});

  static const color = Color(0xfff3f8f8);
  static const itemExtent = 36.0;

  @override
  State<TheDeets> createState() => _TheDeetsState();
}

class _TheDeetsState extends State<TheDeets> {
  bool onlyRefactorPRs = false;
  bool floatingFooter = true;
  double targetExtent = double.infinity;
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      final shouldFloat = controller.offset < targetExtent;
      if (shouldFloat != floatingFooter) {
        setState(() => floatingFooter = shouldFloat);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    onlyRefactorPRs = Refactoring.of(context);
    final padding = EdgeInsets.symmetric(
      horizontal: math.max(
        Stats.insets,
        (MediaQuery.sizeOf(context).width - Stats.maxWidth) / 2,
      ),
    );
    final slivers = [
      SliverMainAxisGroup(
        slivers: [
          const SliverPersistentHeader(
            pinned: true,
            delegate: _TableHeader(),
          ),
          SliverFixedExtentList.list(
            itemExtent: TheDeets.itemExtent,
            children: onlyRefactorPRs ? refactorPRs : flutterPRs,
          ),
        ],
      ),
      SliverLayoutBuilder(builder: (context, constraints) {
        final SliverConstraints(
          :precedingScrollExtent,
          :viewportMainAxisExtent,
          :remainingPaintExtent,
        ) = constraints;

        targetExtent = precedingScrollExtent + 36.0 - viewportMainAxisExtent;

        Widget? total;
        if (remainingPaintExtent >= 36.0) {
          total = PullRequest.total(onlyRefactor: onlyRefactorPRs);
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
      color: TheDeets.color,
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
                  child: PullRequest.total(onlyRefactor: onlyRefactorPRs),
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
  const _TableHeader();

  @override
  final double minExtent = 36.0;
  @override
  final double maxExtent = 36.0;

  @override
  bool shouldRebuild(_TableHeader oldDelegate) => false;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    const header = Row(
      key: GlobalObjectKey('header'),
      children: [
        Expanded(child: Center(child: _TableTitle())),
        SizedBox(
          width: 50,
          child: Center(
            child: Text(
              '+',
              style: TextStyle(
                color: Diffs.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Center(
            child: Text(
              '–',
              style: TextStyle(
                color: Diffs.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Center(
            child: Text(
              'Δ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );

    if (shrinkOffset == 0) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: PullRequest.border),
        ),
        child: header,
      );
    }
    return const ColoredBox(color: Color(0xe0f8ffff), child: header);
  }
}

class _TableTitle extends StatelessWidget {
  const _TableTitle();

  @override
  Widget build(BuildContext context) {
    final descriptor = Refactoring.of(context) ? 'refactoring' : 'contribution';
    return Text(
      'Flutter $descriptor diffs',
      style: const TextStyle(fontWeight: FontWeight.w600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _RefactorButton extends StatelessWidget {
  const _RefactorButton();

  @override
  Widget build(BuildContext context) {
    final onlyRefactorPRs = Refactoring.of(context);

    const padding = WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24, vertical: 18));
    const boringStyle = ButtonStyle(
      side: WidgetStatePropertyAll(
        BorderSide(width: 2, color: Color(0xff80a0a0)),
      ),
      backgroundColor: WidgetStateProperty<Color?>.fromMap({
        WidgetState.selected: Color(0xffc0e0e0),
      }),
      foregroundColor: WidgetStatePropertyAll(Color(0xff406060)),
      padding: padding,
    );
    const refactorStyle = ButtonStyle(
      side: WidgetStatePropertyAll(
        BorderSide(width: 2, color: Color(0xff80ffff)),
      ),
      backgroundColor: WidgetStateProperty<Color?>.fromMap({
        WidgetState.selected: Color(0xff80ffff),
      }),
      foregroundColor: WidgetStatePropertyAll(Colors.black),
      overlayColor: WidgetStateProperty.fromMap({
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
        Route.go(
          Route.stats,
          params: selected.single ? {'refactor': 'true'} : null,
        );
      },
      showSelectedIcon: false,
    );
  }
}
