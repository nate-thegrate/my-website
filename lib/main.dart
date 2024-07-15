import 'the_good_stuff.dart';

void main() => runApp(const App());

enum Route {
  contributions,
  projects;

  GlobalKey get key => GlobalObjectKey(this);

  @override
  String toString() => switch (this) {
        contributions => 'Flutter contributions',
        projects => name,
      };
}

class App extends StatelessWidget {
  const App({super.key});

  static const _scaffoldMessengerKey = GlobalObjectKey<ScaffoldMessengerState>(Scaffold);
  static BuildContext get context => _scaffoldMessengerKey.currentContext!;

  static void go(String location, {Object? extra}) => context.go(location, extra: extra);

  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: <RouteBase>[
          GoRoute(
            path: Route.contributions.toString(),
            builder: (context, state) => const Contributions(),
          ),
          GoRoute(
            path: Route.projects.toString(),
            builder: (context, state) => const Projects(),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
