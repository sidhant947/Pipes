import 'package:flutter/material.dart';
import 'package:pipes/domain/models/app_settings.dart';

class AppColors {
  AppColors._();

  static AppThemePreset currentTheme = AppThemePreset.pastelSky;

  static Color get primary => currentTheme.primary;
  static Color get accent => currentTheme.accent;
  static Color get headingDark => currentTheme.headingDark;
  static Color get headingWhite => currentTheme.headingWhite;
  static Color get subtext => currentTheme.subtext;
  static Color get bg => currentTheme.bg;
  static Color get gridLines => currentTheme.gridLines;
  static Color get surface => currentTheme.surface;
  static Color get border => currentTheme.border;

  static Color get darkBg => bg;
  static Color get darkSurface => surface;
  static Color get darkCard => surface;
  static Color get darkBorder => border;

  static Color get lightBg => bg;
  static Color get lightSurface => surface;
  static Color get lightCard => surface;
  static Color get lightBorder => border;
}

class GameColors {
  GameColors._();

  static const Color bg = Color(0xFF121212);
  static const Color surface = Color(0xFF1C1C1C);
  static const Color primary = Color(0xFF2D2D2D);
  static const Color headingDark = Color(0xFFFFFFFF);
  static const Color headingWhite = Color(0xFF121212);
  static const Color subtext = Color(0xFF888888);
  static const Color gridLines = Color(0xFF2D2D2D);
  static const Color border = Color(0x3DFFFFFF);
}
