import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pipes/data/services/settings_service.dart';
import 'package:pipes/domain/models/app_settings.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';

class SettingsViewModel extends StateNotifier<AppSettings> {
  SettingsViewModel({required this.settingsService})
      : super(settingsService.getSettings()) {
    AppColors.currentTheme = state.theme;
  }

  final SettingsService settingsService;

  Future<void> setTheme(AppThemePreset theme) async {
    AppColors.currentTheme = theme;
    state = state.copyWith(theme: theme);
    await settingsService.saveSettings(state);
  }

  Future<void> toggleHintEnabled(bool value) async {
    state = state.copyWith(isHintEnabled: value);
    await settingsService.saveSettings(state);
  }
}
