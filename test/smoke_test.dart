import 'package:flutter_test/flutter_test.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

void main() {
  testWidgets('navigate between the app screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(3840, 2160));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const App());

    expect(find.text('stats'), findsWidgets);
    expect(find.text('projects'), findsWidgets);

    Future<void> go(Route route, {Duration settle = const Duration(seconds: 1)}) async {
      Route.go(route);
      await tester.pump();
      await tester.pump(settle);
    }

    await go(Route.stats);
    expect(Route.current, Route.stats);
    expect(find.text('Total'), findsWidgets);
    expect(find.text('STATS'), findsOneWidget);

    await go(Route.projects);
    expect(Route.current, Route.projects);
    expect(find.text('PROJECTS'), findsOneWidget);
    expect(find.byType(ProjectGrid), findsWidgets);
  });
}
