import 'dart:ui';

import 'the_good_stuff.dart';

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

  @Deprecated('probably not necessary')
  factory Route.of(BuildContext context) {
    final uri = GoRouter.of(context).routeInformationProvider.value.uri;
    return Route.fromUri(uri);
  }

  static Route get current {
    final uri = App._router.routerDelegate.currentConfiguration.uri;
    return Route.fromUri(uri);
  }

  static void go(Route route, {Map<String, String>? params, Object? extra}) {
    App.context.go(route, params: params, extra: extra);
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

  static GlobalKey<NavigatorState> get _navigatorKey => _router.routerDelegate.navigatorKey;
  static BuildContext get context => _navigatorKey.currentContext!;
  static NavigatorState get vsync => _navigatorKey.currentState!;
  static OverlayState get overlay => vsync.overlay!;

  static final GoRouter _router = GoRouter(
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
      routerConfig: _router,
    );
  }
}

class TopBar extends StatefulWidget {
  const TopBar({super.key, this.body});

  final Widget? body;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> with TickerProviderStateMixin {
  late final gapAnimation = ValueAnimation(
    vsync: this,
    initialValue: 0.0,
    duration: Durations.short2,
    curve: Curves.ease,
    lerp: lerpDouble,
  )..addListener(rebuild);

  @override
  void dispose() {
    gapAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stache(
      child: TheVoid.consume(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight + gapAnimation.value),
            child: MouseRegion(
              onEnter: (event) => gapAnimation.value = 12,
              onExit: (event) => gapAnimation.value = 0,
              child: Column(
                children: [
                  const SizedBox(
                    height: kToolbarHeight,
                    child: ColoredBox(
                      color: GrateColors.lightCyan,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text('NATE THE GRATE', textAlign: TextAlign.center),
                            ),
                          ),
                          _RouteButton(Route.stats),
                          _RouteButton(Route.projects),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: gapAnimation.value,
                    child: const ColoredBox(color: Color(0xff002040)),
                  ),
                ],
              ),
            ),
          ),
          body: widget.body,
        ),
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  const _RouteButton(this.route);

  final Route route;

  @override
  Widget build(BuildContext context) {
    Widget widget = Center(child: Text('$route', textAlign: TextAlign.center));

    if (route == Route.current) {
      widget = ColoredBox(color: Colors.white54, child: widget);
    }
    return Expanded(child: widget);
  }
}
