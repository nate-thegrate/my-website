import 'package:nate_thegrate/the_good_stuff.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  @override
  Widget build(BuildContext context) {
    return const TopBar(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: TheDeets(),
      ),
    );
  }
}

class TheDeets extends StatefulWidget {
  const TheDeets({super.key});

  @override
  State<TheDeets> createState() => _TheDeetsState();
}

class _TheDeetsState extends State<TheDeets> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
