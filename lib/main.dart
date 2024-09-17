import 'the_good_stuff.dart';

export 'home_page/home_page.dart';
export 'stats/stats.dart';
export 'projects/projects.dart';
export 'top_bar/top_bar.dart';

void main() => runApp(const App());

enum Route {
  home,
  stats,
  projects,
  mapping,
  animation,
  hueman,
  flutterApis,
  recipes,
  thisSite;

  factory Route.fromUri(Uri uri) {
    final segments = uri.pathSegments.toList();
    String last = segments.last;

    if (last.contains('true') || last.contains('false')) {
      segments.removeLast();
      last = segments.last;
    }

    try {
      return values.byName(last);
    } on Object {
      throw ArgumentError('uri: $uri, segments: $segments');
    }
  }

  static Route get current {
    final uri = App.router.routerDelegate.currentConfiguration.uri;
    return Route.fromUri(uri);
  }

  static void go(Route route, {Map<String, String>? params, Object? extra}) {
    if (route == Route.home) {
      HomePageElement.instance.fricksToGive = HomePageElement.initialFricks;
    }
    if (params == null) {
      return App.router.go(route.target, extra: extra);
    }
    App.router.goNamed(route.name, pathParameters: params, extra: extra);
  }

  String get target {
    if (this == home) return '/';

    final parent = switch (this) {
      home => throw Error(),
      stats || projects => '',
      hueman || flutterApis || recipes || thisSite => projects.target,
      mapping || animation => flutterApis.target,
    };
    return '$parent/$name';
  }

  GlobalKey get key => GlobalObjectKey(this);

  @override
  String toString() => name;
}

class App extends StatelessWidget {
  const App({super.key});

  static GlobalKey<NavigatorState> get _navigatorKey => router.routerDelegate.navigatorKey;
  static BuildContext get context => _navigatorKey.currentContext!;
  static NavigatorState get vsync => _navigatorKey.currentState!;
  static OverlayState get overlay => vsync.overlay!;

  static Size get screenSize => WidgetsBinding.instance.renderViews.first.size;

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: <RouteBase>[
          GoRoute(
            path: Route.stats.name,
            redirect: (context, state) => '/stats/refactor=false',
          ),
          GoRoute(
            name: Route.stats.name,
            path: 'stats/:refactor',
            pageBuilder: Stats.pageBuilder,
          ),
          GoRoute(
            path: Route.projects.name,
            pageBuilder: (context, state) => const NoTransitionPage(child: Projects()),
            routes: <RouteBase>[
              GoRoute(
                path: Route.flutterApis.name,
                pageBuilder: (context, state) {
                  if (state.extra != null) {
                    return const NoTransitionPage(child: FlutterApisTransition.stack);
                  }
                  return const NoTransitionPage(child: FlutterApis());
                },
                routes: [
                  GoRoute(
                    path: Route.mapping.name,
                    pageBuilder: (context, state) {
                      return const NoTransitionPage(child: WidgetStateMapping());
                    },
                  ),
                  GoRoute(
                    path: Route.animation.name,
                    pageBuilder: (context, state) {
                      return const NoTransitionPage(child: WidgetStateMapping());
                    },
                  ),
                ],
              ),
              GoRoute(
                path: Route.hueman.name,
                redirect: (context, state) => Route.projects.target,
              ),
              GoRoute(
                path: Route.recipes.name,
                pageBuilder: (context, state) => const NoTransitionPage(child: Recipes()),
              ),
              GoRoute(
                path: Route.thisSite.name,
                pageBuilder: (context, state) => const NoTransitionPage(child: ThisSite()),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GrateColors.lightCyan,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: GrateColors.lightCyan,
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

    return MaterialApp.router(
      theme: theme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
