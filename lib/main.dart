import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pipes/data/services/hive_service.dart';
import 'package:pipes/data/services/settings_service.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';
import 'package:pipes/ui/core/theme/app_theme.dart';
import 'package:pipes/ui/providers.dart';
import 'package:pipes/ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final settingsService = SettingsService();
  await settingsService.init();

  final initialSettings = settingsService.getSettings();
  AppColors.currentTheme = initialSettings.theme;

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const PipesApp(),
    ),
  );
}

class PipesApp extends ConsumerWidget {
  const PipesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    AppColors.currentTheme = settings.theme;
    return MaterialApp(
      title: 'Pipes',
      theme: AppTheme.fromPreset(settings.theme),
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
