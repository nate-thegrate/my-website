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
  @override
  Widget build(BuildContext context) {
    const divider = ColoredBox(
      color: Colors.black12,
      child: SizedBox(width: double.infinity, height: 1),
    );
    final prs = onlyRefactor ? refactorPRs : flutterPRs;
    return ColoredBox(
      color: TheDeets.color,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: prs.length + 1,
        itemBuilder: (context, index) => Focus(
          child: prs.elementAtOrNull(index) ?? PullRequest.total(onlyRefactor: onlyRefactor),
        ),
        separatorBuilder: (context, index) => divider,
      ),
    );
  }
}
