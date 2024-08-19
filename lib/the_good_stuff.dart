import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'main.dart';

export 'package:flutter/material.dart' hide Route;
export 'package:flutter/gestures.dart';
export 'package:go_router/go_router.dart' hide GoRouterHelper;
export 'package:provider/provider.dart';
export 'package:url_launcher/url_launcher_string.dart';

export 'main.dart';
export 'home_page/home_page.dart';
export 'stats/stats.dart';
export 'stats/pr_data/pr_data.dart';
export 'projects/projects.dart';

/// This class stores the colors which, objectively speaking,
/// are better than any others.
abstract final class GrateColors {
  static const lightCyan = Color(0xff80ffff);
  static const tolls = Color(0xfff7b943);
}

extension ContextRoute on BuildContext {
  void go(Route route, {Object? extra}) => GoRouter.of(this).go(route.target, extra: extra);
}

typedef Bloc = ChangeNotifier;
typedef Cubit<T> = ValueNotifier<T>;
typedef BlocProvider<T extends Bloc?> = ChangeNotifierProvider<T>;

const root2 = 1.4142135623730951;

class Seconds extends Duration {
  const Seconds(double seconds)
      : super(microseconds: (seconds * Duration.microsecondsPerSecond) ~/ 1);
}

final isMobile = switch (defaultTargetPlatform) {
  TargetPlatform.android || TargetPlatform.fuchsia || TargetPlatform.iOS => true,
  TargetPlatform.linux || TargetPlatform.macOS || TargetPlatform.windows => false,
};
