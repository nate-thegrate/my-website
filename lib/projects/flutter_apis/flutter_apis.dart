import 'package:nate_thegrate/the_good_stuff.dart';

export 'api_buttons.dart';
export 'flutter_apis_card.dart';
export 'animated_render_object_widget.dart';

class FlutterApis extends StatelessWidget {
  const FlutterApis({super.key});

  @override
  Widget build(BuildContext context) {
    const border = BeveledRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    );
    return const RouteProvider(
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: ApiButtons.decoration,
          child: DefaultTextStyle(
            style: ApiButton.style,
            textAlign: TextAlign.center,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 40,
                          child: ApiButton(
                            Route.projects,
                            border: CircleBorder(),
                            child: SizedBox.square(
                              dimension: 200,
                              child: Icon(Icons.arrow_back, size: 125),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ApiButton(
                            Route.mapping,
                            border: BeveledRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Text('Mapping'),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ApiButton(
                            Route.animation,
                            border: BeveledRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Text('Animation'),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipPath(
                    clipper: ShapeBorderClipper(shape: border),
                    child: SizedBox.expand(
                      child: DecoratedBox(
                        decoration: Rekt(depth: 1.0, border: border),
                        position: DecorationPosition.foreground,
                        child: ColoredBox(
                          color: Color(0xff303030),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
