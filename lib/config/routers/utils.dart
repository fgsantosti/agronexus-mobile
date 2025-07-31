import 'package:flutter/material.dart';

enum AppType { techinical, productor }

class RoutesUtils {
  static const Duration duration = Duration(milliseconds: 0);
  static Widget transitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> animation2,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
