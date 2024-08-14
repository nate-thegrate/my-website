import 'package:flutter/material.dart' hide Route;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'main.dart';

export 'package:flutter/material.dart' hide Route;
export 'package:flutter/gestures.dart';
export 'package:go_router/go_router.dart' hide GoRouterHelper;
export 'package:provider/provider.dart';

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
  void go(Route route, {Object? extra}) => GoRouter.of(this).go('/${route.name}', extra: extra);
}

typedef Bloc = ChangeNotifier;
typedef Cubit<T> = ValueNotifier<T>;
typedef BlocProvider<T extends Bloc?> = ChangeNotifierProvider<T>;
