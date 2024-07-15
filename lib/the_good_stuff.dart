import 'dart:ui' show Color;

export 'package:flutter/material.dart' hide Route;
export 'package:flutter/gestures.dart';
export 'package:go_router/go_router.dart';

export 'main.dart';

export 'home_page/home_page.dart';
export 'contributions/contributions.dart';
export 'projects/projects.dart';

/// This class stores the colors which, objectively speaking,
/// are better than any others.
abstract final class TheBestColorsCompletelyUnbiased {
  static const lightCyan = Color(0xff80ffff);
  static const tolls = Color(0xfff7b943);
}
