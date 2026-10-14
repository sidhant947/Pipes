import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';
import 'package:pipes/ui/core/widgets/tangible_button.dart';
import 'package:pipes/ui/features/game/views/game_view.dart';
import 'package:pipes/ui/features/how_to_play/views/how_to_play_view.dart';
import 'package:pipes/ui/features/level_select/views/level_select_view.dart';
import 'package:pipes/ui/features/settings/views/settings_view.dart';
import 'package:pipes/ui/providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.headingDark.withValues(alpha: 0.08),
              offset: const Offset(0, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? AppColors.headingDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final state = ref.watch(homeViewModelProvider);
    AppColors.currentTheme = settings.theme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFFF9800),
                    onTap: () => _launchUrl('https://github.com/sidhant947/Pipes'),
                  ),
                  if (state.progress != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        'Level ${state.progress!.currentLevel}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingDark,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  _circleButton(
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFEF4444),
                    onTap: _openKoFiUrl,
                  ),
                ],
              ),
              const Spacer(flex: 3),
              Text(
                'Pipes',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppColors.headingDark,
                ),
              ),
              const Spacer(flex: 4),
              TangibleButton(
                text: 'Play',
                onPressed: state.isLoading
                    ? null
                    : () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameView(levelNumber: state.progress?.currentLevel ?? 1),
                          ),
                        );
                        ref.read(homeViewModelProvider.notifier).loadProgress();
                      },
              ),
              const SizedBox(height: 16),
              TangibleButton(
                text: 'Levels',
                isSecondary: true,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LevelSelectView(),
                    ),
                  );
                  ref.read(homeViewModelProvider.notifier).loadProgress();
                },
              ),
              const SizedBox(height: 16),
              TangibleButton(
                text: 'Random',
                isSecondary: true,
                onPressed: () => _showDifficultyDialog(context),
              ),
              const SizedBox(height: 16),
              TangibleButton(
                text: 'How to Play',
                isSecondary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HowToPlayView(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TangibleButton(
                text: 'Settings',
                isSecondary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsView(),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openKoFiUrl() async {
    final Uri uri = Uri.parse('https://ko-fi.com/sidhant947');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {}
    }
  }

  void _showDifficultyDialog(BuildContext context) {
    final stages = [
      'Easy',
      'Medium',
      'Hard',
      'Expert',
      'Master',
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Choose Difficulty',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.headingDark,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Play a dynamically generated Pipes puzzle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.subtext,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (final stage in stages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TangibleButton(
                    text: stage,
                    height: 44,
                    isSecondary: true,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameView(
                            levelNumber: 0,
                            isRandom: true,
                            randomDifficulty: stage,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
