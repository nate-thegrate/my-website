import 'dart:ui';

import 'the_good_stuff.dart';

void main() => runApp(const App());

enum Route {
  home,
  stats,
  projects,
  hueman,
  flutterApis,
  recipes,
  heartCenter;

  factory Route.fromUri(Uri uri) => values.byName(uri.path.split('/').last);

  factory Route.of(BuildContext context) {
    return Route.fromUri(GoRouter.of(context).routeInformationProvider.value.uri);
  }

  static Route get current => Route.fromUri(App._router.routerDelegate.currentConfiguration.uri);

  String get target {
    if (this == home) return '/';

    final parent = switch (this) {
      home || stats || projects => '/',
      hueman || flutterApis || recipes || heartCenter => '/projects/',
    };
    return parent + name;
  }

  GlobalKey get key => GlobalObjectKey(this);

  @override
  String toString() => name;
}

class App extends StatelessWidget {
  const App({super.key});

  static const _scaffoldMessengerKey = GlobalObjectKey<ScaffoldMessengerState>(Scaffold);
  static BuildContext get context => _scaffoldMessengerKey.currentContext!;

  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: <RouteBase>[
          GoRoute(
            path: Route.stats.name,
            builder: (context, state) => const Stats(),
            pageBuilder: (context, state) => const NoTransitionPage(child: Stats()),
          ),
          GoRoute(
            path: Route.projects.name,
            builder: (context, state) => const Projects(),
            pageBuilder: (context, state) => const NoTransitionPage(child: Projects()),
            routes: <RouteBase>[
              GoRoute(
                path: Route.flutterApis.name,
                builder: (context, state) => const FlutterApis(),
                pageBuilder: (context, state) => const NoTransitionPage(child: FlutterApis()),
              ),
              GoRoute(
                path: Route.hueman.name,
                redirect: (context, state) => Route.projects.target,
              ),
              GoRoute(
                path: Route.recipes.name,
                builder: (context, state) => const Recipes(),
                pageBuilder: (context, state) => const NoTransitionPage(child: Recipes()),
              ),
              GoRoute(
                path: Route.heartCenter.name,
                builder: (context, state) => const SizedBox.shrink(),
                pageBuilder: (context, state) => const NoTransitionPage(child: SizedBox.shrink()),
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
    );

    return PRLayoutProvider(
      child: MaterialApp.router(
        theme: theme,
        scaffoldMessengerKey: _scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
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
  )..addListener(() => setState(() {}));

  @override
  void dispose() {
    gapAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

class _RouteButton extends StatelessWidget {
  const _RouteButton(this.route);

  final Route route;

  @override
  Widget build(BuildContext context) {
    Widget widget = Center(child: Text('$route', textAlign: TextAlign.center));

    if (route == Route.of(context)) {
      widget = ColoredBox(color: Colors.white54, child: widget);
    }
    return Expanded(child: widget);
  }
}
