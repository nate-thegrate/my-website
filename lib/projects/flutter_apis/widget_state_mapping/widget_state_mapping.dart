import 'package:nate_thegrate/projects/flutter_apis/widget_state_mapping/widget_state_button.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

class ToggleMapping extends Cubit<bool> {
  ToggleMapping([_]) : super(false);

  static bool of(BuildContext context) => context.watch<ToggleMapping>().value;

  void toggle() => value = !value;
}

class WidgetStateMapping extends StatelessWidget {
  const WidgetStateMapping({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterApis(
      child: BlocProvider(
        create: ToggleMapping.new,
        child: Column(
          children: [
            const ApiAppBar(),
            Expanded(
              child: DecoratedBox(
                decoration: RektDecoration(rekt: Rekt.end(Size.zero)),
                child: const AnimatedOpacity(
                  opacity: 1.0,
                  initialValue: 0.0,
                  duration: Durations.long1,
                  child: Column(
                    children: [
                      CodeCaption(),
                      Expanded(flex: 16, child: CodeSample()),
                      WidgetStateButton(),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
