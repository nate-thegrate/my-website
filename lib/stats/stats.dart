import 'package:nate_thegrate/the_good_stuff.dart';

class Stats extends StatefulWidget {
  const Stats() : super(key: const GlobalObjectKey(Stats));

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
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
  final controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    final prs = onlyRefactor ? refactorPRs : flutterPRs;
    return ColoredBox(
      color: TheDeets.color,
      child: CustomScrollView(
        controller: controller,
        slivers: [
          const SliverPersistentHeader(
            pinned: true,
            delegate: _TableHeader(),
          ),
          SliverFixedExtentList.builder(
            itemCount: prs.length,
            itemExtent: 36.0,
            itemBuilder: (context, index) => prs[index],
          ),
          SliverToBoxAdapter(
            child: PullRequest.total(onlyRefactor: onlyRefactor),
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
    const header = Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'pull request title',
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
      ),
    );

    if (shrinkOffset == 0) return header;
    return const ColoredBox(color: Color(0xe0f8ffff), child: header);
  }
}
