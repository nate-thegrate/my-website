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

  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const HomePage();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'details',
            builder: (context, state) {
              return const Scaffold();
            },
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
