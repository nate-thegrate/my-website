import 'package:nate_thegrate/projects/flutter_apis/api_button.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

export 'widget_state_mapping/widget_state_mapping.dart';
export 'package:nate_thegrate/projects/flutter_apis/rekt.dart';

class FlutterApis extends StatelessWidget {
  const FlutterApis({super.key, this.child = _child});

  static const _child = Row(
    children: [
      ApiButton(Route.mapping),
      ApiButton(Route.animation),
    ],
  );

  final Widget child;

  static const bgImage = AssetImage('assets/images/gradient.png');
  static const decoration = BoxDecoration(
    color: Color(0xff28ffff),
    image: DecorationImage(
      alignment: Alignment.topLeft,
      fit: BoxFit.fill,
      image: bgImage,
      filterQuality: FilterQuality.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: GetRekt.new,
      child: DecoratedBox(
        decoration: decoration,
        child: SizedBox.expand(child: child),
      ),
    );
  }
}

class ApiAppBar extends StatelessWidget {
  const ApiAppBar({super.key});

  static void _back() {
    FlutterApisCard.launching = false;
    Route.go(Route.projects);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: kToolbarHeight,
      child: Row(
        children: [
          BackButton(onPressed: _back),
          ApiButton.appBar(Route.mapping),
          ApiButton.appBar(Route.animation),
          // Expanded(child: Center(child: Text('Mapping'))),
          // Expanded(child: Center(child: Text('Animation'))),
        ],
      ),
    );
  }
}
