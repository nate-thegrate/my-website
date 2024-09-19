import 'package:nate_thegrate/the_good_stuff.dart';

export 'widget_state_mapping/widget_state_mapping.dart';
export 'package:nate_thegrate/projects/flutter_apis/rekt.dart';

class BigApiButtons extends StatelessWidget {
  const BigApiButtons({super.key});

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
  static const stack = Stack(
    fit: StackFit.expand,
    children: [BigApiButtons(), FlutterApisTransition()],
  );

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: decoration,
      child: DefaultTextStyle(
        style: ApiButton.style,
        textAlign: TextAlign.center,
        child: SizedBox.expand(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Spacer(),
              Expanded(
                flex: 9,
                child: ApiButton(
                  Route.mapping,
                  child: Text('WidgetState\nMapping'),
                ),
              ),
              Spacer(),
              Expanded(
                flex: 9,
                child: ApiButton(
                  Route.animation,
                  child: Text('Animated\nValues'),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
