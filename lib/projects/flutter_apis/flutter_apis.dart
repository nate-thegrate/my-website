import 'package:nate_thegrate/the_good_stuff.dart';

class FlutterApis extends StatelessWidget {
  const FlutterApis({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff28ffff), Color(0xffa0a0ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}
