import 'package:flutter/material.dart';
import 'package:pipes/domain/models/app_settings.dart';

class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class AppTheme {
  AppTheme._();

  static const _noTransitionTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _NoTransitionBuilder(),
      TargetPlatform.iOS: _NoTransitionBuilder(),
      TargetPlatform.linux: _NoTransitionBuilder(),
      TargetPlatform.macOS: _NoTransitionBuilder(),
      TargetPlatform.windows: _NoTransitionBuilder(),
      TargetPlatform.fuchsia: _NoTransitionBuilder(),
    },
  );

  static ThemeData fromPreset(AppThemePreset preset) {
    final isLight = !preset.isDark;
    return ThemeData(
      pageTransitionsTheme: _noTransitionTheme,
      brightness: isLight ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: preset.bg,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: preset.headingDark,
        ),
        iconTheme: IconThemeData(color: preset.headingDark),
      ),
      dividerTheme: DividerThemeData(
        color: preset.border,
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: preset.headingDark),
        displayMedium: TextStyle(color: preset.headingDark),
        displaySmall: TextStyle(color: preset.headingDark),
        headlineLarge: TextStyle(color: preset.headingDark),
        headlineMedium: TextStyle(color: preset.headingDark),
        headlineSmall: TextStyle(color: preset.headingDark),
        titleLarge: TextStyle(color: preset.headingDark),
        titleMedium: TextStyle(color: preset.headingDark),
        bodyLarge: TextStyle(color: preset.headingDark, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: preset.subtext, fontWeight: FontWeight.normal),
        labelLarge: TextStyle(color: preset.headingDark, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get light => fromPreset(AppThemePreset.pastelSky);
  static ThemeData get dark => fromPreset(AppThemePreset.obsidian);
}
