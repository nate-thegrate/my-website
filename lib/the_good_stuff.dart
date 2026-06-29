import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get_hooked/get_hooked.dart';
import 'package:go_router/go_router.dart' hide GoRouterHelper;

import 'home_page/home_page.dart';
import 'projects/projects.dart';
import 'stats/stats.dart';
import 'top_bar/top_bar.dart';

export 'package:flutter/foundation.dart';
export 'package:flutter/gestures.dart';
export 'package:flutter/material.dart'
    hide AnimatedSlide, ChangeNotifier, Route, SlideTransition, ValueNotifier;
export 'package:flutter/rendering.dart';
export 'package:flutter/scheduler.dart';
export 'package:get_hooked/get_hooked.dart';
export 'package:go_router/go_router.dart' hide GoRouterHelper;
export 'package:url_launcher/url_launcher_string.dart';

export 'home_page/home_page.dart';
export 'projects/projects.dart';
export 'stats/stats.dart';
export 'top_bar/top_bar.dart';

part 'route.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const _navigatorKey = GlobalObjectKey<NavigatorState>(Navigator);
  static BuildContext get context => _navigatorKey.currentContext!;
  static NavigatorState get vsync => _navigatorKey.currentState!;
  static OverlayState get overlay => vsync.overlay!;

  static Size get screenSize => WidgetsBinding.instance.renderViews.first.size;

  static final _theme = ThemeData(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(seedColor: TopBar.background),
    textSelectionTheme: const TextSelectionThemeData(selectionColor: TopBar.background),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xff0060ff),
        shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        .android: CupertinoPageTransitionsBuilder(),
        .iOS: CupertinoPageTransitionsBuilder(),
        .macOS: CupertinoPageTransitionsBuilder(),
        .windows: CupertinoPageTransitionsBuilder(),
        .fuchsia: CupertinoPageTransitionsBuilder(),
        .linux: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultAnimationStyle(
      style: const AnimationStyle(curve: Curves.ease),
      child: MaterialApp.router(
        theme: _theme,
        debugShowCheckedModeBanner: false,
        routerConfig: _goRouter,
      ),
    );
  }
}

mixin MarkNeedsBuild<T extends StatefulWidget> on State<T> {
  late final rebuild = (context as Element).markNeedsBuild;
}

extension FindRenderBox on BuildContext {
  RenderBox get renderBox => findRenderObject()! as RenderBox;
}

class BigBox extends RenderBox {
  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performResize() => size = constraints.biggest;
}

typedef Bloc = ChangeNotifier;
typedef Cubit<T> = ValueNotifier<T>;

extension ToggleCubit on Cubit<bool> {
  void toggle() => value = !value;
}

T findWidget<T extends Widget>(BuildContext context) {
  return context.findAncestorWidgetOfExactType<T>()!;
}

bool hasAncestor<T extends Widget>(BuildContext context) {
  return context.findAncestorWidgetOfExactType<T>() != null;
}

void postFrameCallback(VoidCallback callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) => callback());
}

typedef _States = SetNotifier<WidgetState>;
extension type WidgetStates._(_States _states) implements _States {
  WidgetStates([_]) : _states = _States();

  static WidgetStates? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<WidgetStatesProvider>()?.notifier;
  }

  static Set<WidgetState> of(BuildContext context) {
    return RecursionCount.of(context) > 0
        ? <WidgetState>{}
        : context.dependOnInheritedWidgetOfExactType<WidgetStatesProvider>()!.notifier!;
  }
}

class WidgetStatesProvider extends InheritedNotifier<WidgetStates> {
  const WidgetStatesProvider({super.key, required WidgetStates states, required super.child})
    : super(notifier: states);
}
