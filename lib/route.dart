part of 'main.dart';

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
    final segments = uri.pathSegments;
    final name = segments.last.contains('true') || segments.last.contains('false')
        ? segments[segments.length - 2]
        : segments.last;

    try {
      return values.byName(name);
    } on Object {
      throw ArgumentError('uri: $uri, segments: ${uri.pathSegments}');
    }
  }

  factory Route.of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_RouteProvider>()?.route ?? current;
  }

  static Route get current => _current.value;
  static final _current = Cubit(home);

  static void go(Route route, {Map<String, String>? params, Object? extra}) {
    _current.value = route;
    if (route == Route.home) {
      HomePageElement.instance.fricksToGive = HomePageElement.initialFricks;
    }

    if (params == null) {
      return _goRouter.go(route.uri, extra: extra);
    }
    _goRouter.goNamed(route.name, pathParameters: params, extra: extra);
  }

  String get uri {
    if (this == home) return '/';

    final parent = switch (this) {
      home => throw Error(),
      stats || projects => '',
      hueman || flutterApis || recipes || thisSite => projects.uri,
      mapping || animation => flutterApis.uri,
    };
    return '$parent/$name';
  }

  static Route? destination;
  static void travel([_]) async {
    destination = TopBar.focused;
    switch (destination) {
      case home:
        App.overlay.insert(NoMoreCSS.entry);
        HomePageElement.instance.fricksToGive = HomePageElement.initialFricks;
        await Future.delayed(const Duration(microseconds: RenderNoMoreCSS.fadeInMicros));
        destination = null;

      case stats || projects:
        App.overlay.insert(Blank.entry);
        await Future.delayed(Blank.duration);
        go(destination!);
        Blank.entry.remove();
        destination = null;

      default:
        throw Error();
    }
  }

  GlobalKey get key => GlobalObjectKey(this);

  @override
  String toString() => name;
}

class RouteProvider extends HookWidget {
  const RouteProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _RouteProvider(route: useValueListenable(Route._current), child: child);
  }
}

class _RouteProvider extends InheritedWidget {
  const _RouteProvider({required this.route, required super.child});

  final Route route;

  @override
  bool updateShouldNotify(_RouteProvider oldWidget) => oldWidget.route != route;
}

final _goRouter = GoRouter(
  navigatorKey: App._navigatorKey,
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
                  return const NoTransitionPage(child: BigApiButtons.stack);
                }
                return const NoTransitionPage(child: BigApiButtons());
              },
              routes: [
                GoRoute(
                  path: Route.mapping.name,
                  pageBuilder: (context, state) {
                    return const NoTransitionPage(child: FlutterApis());
                  },
                ),
                GoRoute(
                  path: Route.animation.name,
                  pageBuilder: (context, state) {
                    return const NoTransitionPage(child: FlutterApis());
                  },
                ),
              ],
            ),
            GoRoute(
              path: Route.hueman.name,
              redirect: (context, state) => Route.projects.uri,
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
