import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/rendering.dart' as render;
import 'package:provider/provider.dart';

import 'main.dart';

export 'package:flutter/material.dart' hide Route, RenderBox;
export 'package:flutter/gestures.dart';
export 'package:flutter/foundation.dart';
export 'package:flutter/rendering.dart' hide RenderBox;
export 'package:flutter/scheduler.dart';
export 'package:go_router/go_router.dart' hide GoRouterHelper;
export 'package:provider/provider.dart' hide ChangeNotifierProvider, Dispose;
export 'package:flutter_hooks/flutter_hooks.dart';
export 'package:url_launcher/url_launcher_string.dart';

export 'main.dart';

extension Rebuild on State {
  // ignore: invalid_use_of_protected_member, screw that
  void rebuild() => setState(() {});
}

class RenderBox extends render.RenderBox {
  @override
  void performLayout() => size = constraints.biggest;
}

typedef Bloc = ChangeNotifier;
typedef Cubit<T> = ValueNotifier<T>;
typedef BlocProvider<T extends Bloc?> = ChangeNotifierProvider<T>;

extension type WidgetStates._(SetNotifier<WidgetState> _states)
    implements SetNotifier<WidgetState> {
  WidgetStates([_]) : _states = SetNotifier<WidgetState>();

  static Set<WidgetState> of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ThisSiteCard>() != null
        ? <WidgetState>{}
        : context.watch<WidgetStates>();
  }
}
