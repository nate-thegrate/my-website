import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'main.dart';

export 'package:flutter/material.dart' hide Route;
export 'package:flutter/foundation.dart';
export 'package:flutter/gestures.dart';
export 'package:flutter/rendering.dart';
export 'package:flutter/scheduler.dart';
export 'package:flutter_hooks/flutter_hooks.dart';
export 'package:go_router/go_router.dart' hide GoRouterHelper;
export 'package:provider/provider.dart' hide ChangeNotifierProvider, Dispose;
export 'package:url_launcher/url_launcher_string.dart';

export 'main.dart';

extension Rebuild on State {
  // ignore: invalid_use_of_protected_member, screw that
  void rebuild() => setState(() {});
}

extension FindRenderBox on BuildContext {
  RenderBox get renderBox => findRenderObject()! as RenderBox;
}

mixin BiggestBox on RenderBox {
  @override
  void performLayout() => size = constraints.biggest;
}

typedef Bloc = ChangeNotifier;
typedef Cubit<T> = ValueNotifier<T>;
typedef BlocProvider<T extends Bloc?> = ChangeNotifierProvider<T>;

extension ToggleCubit on Cubit<bool> {
  void toggle() => value = !value;
}

/// The [s] parameter selects a [ValueListenable] from the given [State].
ValueListenable<T> useAnimationFrom<S extends State, T>(ValueListenable<T> Function(S s) s) {
  final context = useContext();
  return useMemoized(() => s(context.findAncestorStateOfType<S>()!));
}

void postFrameCallback(VoidCallback callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) => callback());
}

typedef _States = SetNotifier<WidgetState>;
extension type WidgetStates._(_States _states) implements _States {
  WidgetStates([_]) : _states = _States();

  static Set<WidgetState> of(BuildContext context) {
    return RecursionCount.of(context) > 0 ? <WidgetState>{} : context.watch<WidgetStates>();
  }
}
