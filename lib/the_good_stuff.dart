import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:flutter/material.dart'
    hide Route, AnimationController, ChangeNotifier, ValueNotifier;
export 'package:flutter/foundation.dart';
export 'package:flutter/gestures.dart';
export 'package:flutter/rendering.dart';
export 'package:flutter/scheduler.dart';
export 'package:flutter_hooks/flutter_hooks.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart' hide describeIdentity, shortHash;
export 'package:go_router/go_router.dart' hide GoRouterHelper;
export 'package:url_launcher/url_launcher_string.dart';
export 'package:meta/meta.dart' show redeclare;

export 'main.dart';

extension Rebuild on State {
  // ignore: invalid_use_of_protected_member, screw that
  void rebuild() => setState(() {});
}

extension FindRenderBox on BuildContext {
  RenderBox get renderBox => findRenderObject()! as RenderBox;

  ProviderContainer get ref => ProviderScope.containerOf(this);
}

mixin BiggestBox on RenderBox {
  @override
  void performLayout() => size = constraints.biggest;
}

typedef Bloc = ChangeNotifier;
typedef Cubit<T> = ValueNotifier<T>;

extension ToggleCubit on Cubit<bool> {
  void toggle() => value = !value;
}

typedef AnimationController = ValueListenable<double>;

AnimationController useControllerFrom<S extends State>(AnimationController Function(S s) s) {
  return useAnimationFrom(s);
}

ValueListenable<T> useAnimationFrom<S extends State, T>(ValueListenable<T> Function(S s) s) {
  final context = useContext();
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
