part of 'main.dart';

final bool mobile = switch (defaultTargetPlatform) {
  TargetPlatform.android || TargetPlatform.iOS => true,
  TargetPlatform() => false,
};

enum Route {
  home,
  stats,
  projects,
  refactorStats,
  mapping,
  animation,
  hueman,
  dx,
  recipes,
  source;

  factory Route.fromUri(Uri uri) {
    final List<String> segments = uri.pathSegments;
    final String name = switch (segments.last) {
      final String s when !s.contains('true') && !s.contains('false') => s,
      _ => segments[segments.length - 2],
    };

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
  static set current(Route newValue) {
    _current.value = newValue;
  }

  static void go(Route route, {Map<String, String>? params, Object? extra}) {
    _current.value = route == refactorStats ? stats : route;
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

    final String parent = switch (this) {
      home => throw Error(),
      stats || refactorStats || projects => '',
      hueman || dx || recipes || source => projects.uri,
      mapping || animation => dx.uri,
    };
    return '$parent/$name';
  }

  static Route? destination;
  static void travel([_]) async {
    destination = TopBar.focused;
    if (destination == current) return;

    switch (destination) {
      case home:
        App.overlay.insert(NoMoreCSS.entry);
        HomePageElement.instance.fricksToGive = HomePageElement.initialFricks;
        await Future<void>.delayed(const Duration(microseconds: RenderNoMoreCSS.fadeInMicros));
        destination = null;

      case stats || projects:
        App.overlay.insert(Blank.entry);
        await Future<void>.delayed(Blank.duration + Durations.short1);
        go(destination!);
        Blank.entry.remove();
        destination = null;

      // ignore: no_default_cases, to make things concise :)
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
      builder: mobile
          ? (context, state) => const MobileHomePage()
          : (context, state) => const DesktopHomePage(),
      routes: [
        _GoRoute.redirect(Route.stats, '/stats/refactor=false'),
        _GoRoute.redirect(Route.refactorStats, '/stats/refactor=true'),
        GoRoute(
          name: Route.stats.name,
          path: 'stats/:refactor',
          pageBuilder: Stats.pageBuilder,
        ),
        _GoRoute(
          Route.projects,
          const _Page(Projects()),
          routes: [
            GoRoute(
              path: Route.dx.name,
              pageBuilder: DX.pageBuilder,
              routes: [
                _GoRoute(Route.mapping, const _Page(DemoScreen())),
                _GoRoute(Route.animation, const _Page(DemoScreen())),
              ],
            ),
            _GoRoute.redirect(Route.hueman, Route.projects.uri),
            _GoRoute(Route.recipes, const _Page(Recipes())),
            _GoRoute(Route.source, const _Page(Source())),
          ],
        ),
      ],
    ),
  ],
);

class _Page extends NoTransitionPage<void> {
  const _Page(Widget child) : super(child: child);
}

extension type _GoRoute._(GoRoute _route) implements GoRoute {
  _GoRoute(Route route, Page<void> page, {List<RouteBase> routes = const []})
      : _route = GoRoute(path: route.name, pageBuilder: (context, state) => page, routes: routes);

  _GoRoute.redirect(Route route, String uri)
      : _route = GoRoute(path: route.name, redirect: (context, state) => uri);
}
