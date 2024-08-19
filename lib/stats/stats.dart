import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

class Stats extends StatefulWidget {
  const Stats() : super(key: const GlobalObjectKey(Stats));

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  // Refactor once TopBar is functional
  @override
  Widget build(BuildContext context) {
    return const TopBar(body: TheDeets());
  }
}

class TheDeets extends StatefulWidget {
  const TheDeets({super.key});

  static const color = Color(0xfff3f8f8);

  @override
  State<TheDeets> createState() => _TheDeetsState();
}

class _TheDeetsState extends State<TheDeets> {
  bool onlyRefactor = false;
  bool floatingFooter = true;
  final controller = ScrollController();
  double targetExtent = double.infinity;

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

  Widget _buildFooter(BuildContext context, SliverConstraints constraints) {
    targetExtent = constraints.precedingScrollExtent + 36.0 - constraints.viewportMainAxisExtent;
    final shouldShow = constraints.remainingPaintExtent >= 36.0;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 36.0,
        child: shouldShow ? PullRequest.total(onlyRefactor: onlyRefactor) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.symmetric(
      horizontal: math.max(14, (MediaQuery.sizeOf(context).width - 720) / 2),
    );
    final slivers = [
      SliverMainAxisGroup(
        slivers: [
          const SliverPersistentHeader(
            pinned: true,
            delegate: _TableHeader(),
          ),
          SliverFixedExtentList.list(
            itemExtent: 36.0,
            children: onlyRefactor ? refactorPRs : flutterPRs,
          ),
        ],
      ),
      SliverLayoutBuilder(builder: _buildFooter),
      const SliverToBoxAdapter(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: PullRequest.borderColor),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 200,
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
                  child: PullRequest.total(onlyRefactor: onlyRefactor),
                ),
              ),
            ),
        ],
      ),
    );
  }
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
        Expanded(
          child: Center(
            child: Text(
              'Flutter contribution diffs',
              style: TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
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
