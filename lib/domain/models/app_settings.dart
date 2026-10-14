import 'package:flutter/material.dart';

enum AppThemePreset {
  pastelMint(
    id: 'pastelMint',
    displayName: 'Mint & Sage',
    bg: Color(0xFFEAF5ED),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFFA5D6A7),
    headingDark: Color(0xFF1B4D3E),
    headingWhite: Color(0xFF0F382C),
    subtext: Color(0xFF4A7C59),
    gridLines: Color(0xFFC8E6C9),
    accent: Color(0xFF388E3C),
    border: Color(0xFFA5D6A7),
  ),
  pastelPeach(
    id: 'pastelPeach',
    displayName: 'Warm Peach',
    bg: Color(0xFFFFF3E0),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFFFFCC80),
    headingDark: Color(0xFF4E2A00),
    headingWhite: Color(0xFF381D00),
    subtext: Color(0xFF8C5C26),
    gridLines: Color(0xFFFFE0B2),
    accent: Color(0xFFE65100),
    border: Color(0xFFFFB74D),
  ),
  pastelLavender(
    id: 'pastelLavender',
    displayName: 'Soft Lavender',
    bg: Color(0xFFF3E5F5),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFFCE93D8),
    headingDark: Color(0xFF3A1C47),
    headingWhite: Color(0xFF281133),
    subtext: Color(0xFF6B437C),
    gridLines: Color(0xFFE1BEE7),
    accent: Color(0xFF7B1FA2),
    border: Color(0xFFBA68C8),
  ),
  pastelSky(
    id: 'pastelSky',
    displayName: 'Cloud Sky',
    bg: Color(0xFFE1F5FE),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF81D4FA),
    headingDark: Color(0xFF013A63),
    headingWhite: Color(0xFF012A4A),
    subtext: Color(0xFF2A6F97),
    gridLines: Color(0xFFB3E5FC),
    accent: Color(0xFF0288D1),
    border: Color(0xFF4FC3F7),
  ),
  pastelRose(
    id: 'pastelRose',
    displayName: 'Pastel Rose',
    bg: Color(0xFFFCE4EC),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFFF48FB1),
    headingDark: Color(0xFF4A1525),
    headingWhite: Color(0xFF360C19),
    subtext: Color(0xFF883955),
    gridLines: Color(0xFFF8BBD0),
    accent: Color(0xFFC2185B),
    border: Color(0xFFF06292),
  ),
  pastelButter(
    id: 'pastelButter',
    displayName: 'Honey Butter',
    bg: Color(0xFFFFFDE7),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFFFFE082),
    headingDark: Color(0xFF423800),
    headingWhite: Color(0xFF2D2600),
    subtext: Color(0xFF7A6A10),
    gridLines: Color(0xFFFFF59D),
    accent: Color(0xFFF57F17),
    border: Color(0xFFFFD54F),
  ),
  pastelCoral(
    id: 'pastelCoral',
    displayName: 'Sweet Coral',
    bg: Color(0xFFFFEBE6),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFFFFAB91),
    headingDark: Color(0xFF4D1C10),
    headingWhite: Color(0xFF38120A),
    subtext: Color(0xFF8D4434),
    gridLines: Color(0xFFFFCCBC),
    accent: Color(0xFFD84315),
    border: Color(0xFFFF8A65),
  ),
  pastelOcean(
    id: 'pastelOcean',
    displayName: 'Aqua Breeze',
    bg: Color(0xFFE0F2F1),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF80CBC4),
    headingDark: Color(0xFF00363A),
    headingWhite: Color(0xFF002528),
    subtext: Color(0xFF00695C),
    gridLines: Color(0xFFB2DFDB),
    accent: Color(0xFF00695C),
    border: Color(0xFF4DB6AC),
  ),
  obsidian(
    id: 'obsidian',
    displayName: 'Obsidian Dark',
    bg: Color(0xFF121212),
    surface: Color(0xFF1C1C1C),
    primary: Color(0xFF2D2D2D),
    headingDark: Color(0xFFFFFFFF),
    headingWhite: Color(0xFF121212),
    subtext: Color(0xFF888888),
    gridLines: Color(0xFF2D2D2D),
    accent: Color(0xFF81C784),
    border: Color(0x3DFFFFFF),
  );

  const AppThemePreset({
    required this.id,
    required this.displayName,
    required this.bg,
    required this.surface,
    required this.primary,
    required this.headingDark,
    required this.headingWhite,
    required this.subtext,
    required this.gridLines,
    required this.accent,
    required this.border,
  });

  final String id;
  final String displayName;
  final Color bg;
  final Color surface;
  final Color primary;
  final Color headingDark;
  final Color headingWhite;
  final Color subtext;
  final Color gridLines;
  final Color accent;
  final Color border;

  static AppThemePreset fromId(String? id) {
    return AppThemePreset.values.firstWhere(
      (e) => e.id == id,
      orElse: () => AppThemePreset.pastelSky,
    );
  }

  bool get isDark => bg.computeLuminance() < 0.5;
}

@immutable
class AppSettings {
  const AppSettings({
    this.isHintEnabled = false,
    this.theme = AppThemePreset.pastelSky,
  });

  final bool isHintEnabled;
  final AppThemePreset theme;

  AppSettings copyWith({
    bool? isHintEnabled,
    AppThemePreset? theme,
  }) {
    return AppSettings(
      isHintEnabled: isHintEnabled ?? this.isHintEnabled,
      theme: theme ?? this.theme,
    );
  }
}
