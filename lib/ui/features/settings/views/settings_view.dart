import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pipes/domain/models/app_settings.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';
import 'package:pipes/ui/core/widgets/tangible_button.dart';
import 'package:pipes/ui/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.headingDark.withValues(alpha: 0.08),
                            offset: const Offset(0, 3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.headingDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.headingDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 46,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppThemePreset.values.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final preset = AppThemePreset.values[index];
                        final isSelected = settings.theme == preset;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(settingsProvider.notifier)
                                .setTheme(preset);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: preset.bg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? preset.accent
                                    : preset.border,
                                width: isSelected ? 2.5 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: preset.accent.withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: preset.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  _divider(),

                  _gameToggle(
                    label: 'Hints',
                    value: settings.isHintEnabled,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleHintEnabled(val);
                    },
                  ),

                  _divider(),

                  const SizedBox(height: 8),
                  TangibleButton(
                    text: 'Become a Backer',
                    height: 48,
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.headingDark,
                    borderColor: AppColors.border,
                    onPressed: () => _openUrl('https://liberapay.com/sidhant947/donate'),
                  ),
                  const SizedBox(height: 12),
                  TangibleButton(
                    text: 'Reset Progress',
                    isSecondary: true,
                    height: 48,
                    backgroundColor: AppColors.surface,
                    textColor: const Color(0xFFFF5252),
                    borderColor: const Color(0x55FF5252),
                    onPressed: () => _confirmReset(context, ref),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.25),
      margin: const EdgeInsets.symmetric(vertical: 18),
    );
  }

  Widget _gameToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.headingDark,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: value
                    ? AppColors.accent
                    : AppColors.headingDark.withValues(alpha: 0.12),
                border: Border.all(
                  color: value ? AppColors.accent : AppColors.border,
                  width: 1.0,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        offset: const Offset(0, 1.5),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF5252).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reset progress?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'All solved puzzles, best times, and saved games will be permanently erased.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: AppColors.subtext,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TangibleButton(
                      text: 'Cancel',
                      isSecondary: true,
                      height: 44,
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TangibleButton(
                      text: 'Reset',
                      backgroundColor: const Color(0xFFD32F2F),
                      textColor: Colors.white,
                      borderColor: const Color(0xFFFF5252),
                      height: 44,
                      onPressed: () async {
                        await ref
                            .read(homeViewModelProvider.notifier)
                            .resetProgress();
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
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
}
