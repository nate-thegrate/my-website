import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart';
import 'package:get_hooked/get_hooked.dart';

import 'main.dart';

export 'package:flutter/foundation.dart';
export 'package:flutter/gestures.dart';
export 'package:flutter/material.dart'
    hide AnimatedSlide, ChangeNotifier, Route, SlideTransition, ValueNotifier;
export 'package:flutter/rendering.dart';
export 'package:flutter/scheduler.dart';
export 'package:get_hooked/get_hooked.dart';
export 'package:go_router/go_router.dart' hide GoRouterHelper;
export 'package:url_launcher/url_launcher_string.dart';

export 'main.dart';

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

T useAnimationFrom<S extends State, T>(T Function(S s) s) {
  final BuildContext context = useContext();
  return useMemoized(() => s(context.findAncestorStateOfType<S>()!));
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
