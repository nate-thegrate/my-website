import 'the_good_stuff.dart';

export 'home_page/home_page.dart';
export 'projects/projects.dart';
export 'stats/stats.dart';
export 'top_bar/top_bar.dart';

part 'route.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  static const _navigatorKey = GlobalObjectKey<NavigatorState>(Navigator);
  static BuildContext get context => _navigatorKey.currentContext!;
  static NavigatorState get vsync => _navigatorKey.currentState!;
  static OverlayState get overlay => vsync.overlay!;

  static Size get screenSize => WidgetsBinding.instance.renderViews.first.size;

  static final _theme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TopBar.background,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: TopBar.background,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xff0060ff),
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: _theme,
      debugShowCheckedModeBanner: false,
      routerConfig: _goRouter,
    );
  }
}
