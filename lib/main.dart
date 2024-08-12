import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'the_good_stuff.dart';

void main() => runApp(const App());

enum Route {
  stats,
  projects;

  factory Route.fromUri(Uri uri) => values.byName(uri.path.split('/').last);

  factory Route.of(BuildContext context) {
    return Route.fromUri(GoRouter.of(context).routeInformationProvider.value.uri);
  }

  static Route get current => Route.fromUri(App._router.routerDelegate.currentConfiguration.uri);

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
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: GrateColors.lightCyan,
        ),
        textSelectionTheme: const TextSelectionThemeData(selectionColor: GrateColors.lightCyan),
      ),
      scaffoldMessengerKey: _scaffoldMessengerKey,
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
    tickerProvider: this,
    initialValue: 0.0,
    duration: Durations.short2,
    curve: Curves.ease,
    lerp: ui.lerpDouble,
  )..addListener(() => setState(() {}));

  @override
  Widget build(BuildContext context) {
    final currentRoute = Route.of(context);

    Widget routeButton(Route route) {
      Widget widget = Center(child: Text('$route', textAlign: TextAlign.center));

      if (route == currentRoute) {
        widget = ColoredBox(color: Colors.white54, child: widget);
      }
      return Expanded(child: widget);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + gapAnimation.value),
        child: MouseRegion(
          onEnter: (event) => gapAnimation.value = 12,
          onExit: (event) => gapAnimation.value = 0,
          child: Column(
            children: [
              SizedBox(
                height: kToolbarHeight,
                child: ColoredBox(
                  color: GrateColors.lightCyan,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(
                        child: Center(
                          child: Text('NATE THE GRATE ($kIsWasm)', textAlign: TextAlign.center),
                        ),
                      ),
                      for (final route in Route.values) routeButton(route),
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
