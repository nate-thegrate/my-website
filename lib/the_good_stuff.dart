import 'package:collection_notifiers/collection_notifiers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:go_router/go_router.dart';
import 'package:nate_thegrate/projects/projects.dart';
import 'package:provider/provider.dart';

import 'main.dart';

export 'package:flutter/material.dart' hide Route;
export 'package:flutter/gestures.dart';
export 'package:flutter/foundation.dart';
export 'package:flutter/rendering.dart';
export 'package:flutter/scheduler.dart';
export 'package:go_router/go_router.dart' hide GoRouterHelper;
export 'package:provider/provider.dart' hide ChangeNotifierProvider, Dispose;
export 'package:flutter_hooks/flutter_hooks.dart';
export 'package:url_launcher/url_launcher_string.dart';

export 'main.dart';
export 'home_page/home_page.dart';
export 'stats/stats.dart';
export 'stats/pr_data/pr_data.dart';
export 'projects/projects.dart';
export 'projects/recipes/recipes.dart';
export 'projects/recipes/delayed_activation_hook.dart';
export 'projects/this_site/this_site.dart';
export 'top_bar/top_bar.dart';

/// This class stores the colors which, objectively speaking,
/// are better than any others.
abstract final class GrateColors {
  static const lightCyan = Color(0xff80ffff);
  static const tolls = Color(0xfff7b943);
}

extension ContextRoute on BuildContext {
  void go(Route route, {Map<String, String>? params, Object? extra}) {
    if (params == null) {
      return GoRouter.of(this).go(route.target, extra: extra);
    }
    GoRouter.of(this).goNamed(route.name, pathParameters: params, extra: extra);
  }
}

extension Rebuild on State {
  // ignore: invalid_use_of_protected_member, screw that
  void rebuild() => setState(() {});
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

const root2 = 1.4142135623730951;
const microPerSec = Duration.microsecondsPerSecond;

final isMobile = switch (defaultTargetPlatform) {
  TargetPlatform.android || TargetPlatform.fuchsia || TargetPlatform.iOS => true,
  TargetPlatform.linux || TargetPlatform.macOS || TargetPlatform.windows => false,
};
