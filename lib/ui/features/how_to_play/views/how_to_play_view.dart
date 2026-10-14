import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';
import 'package:pipes/ui/core/widgets/tangible_button.dart';
import 'package:pipes/ui/providers.dart';

class HowToPlayView extends ConsumerWidget {
  const HowToPlayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    AppColors.currentTheme = settings.theme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.headingDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'How to Play',
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  _guideStep(
                    stepNumber: '1',
                    title: 'Goal',
                    description: 'Connect every pipe on the grid so water flows from the source to every single pipe.',
                  ),
                  const SizedBox(height: 16),
                  _guideStep(
                    stepNumber: '2',
                    title: 'Water Source',
                    description: 'The source is at the center tile. Water automatically flows through any aligned, matching pipe connections.',
                  ),
                  const SizedBox(height: 16),
                  _guideStep(
                    stepNumber: '3',
                    title: 'Rotate Pipes',
                    description: 'Tap any pipe tile to rotate it 90° clockwise. Align each pipe with adjacent neighbors to expand the water circuit.',
                  ),
                  const SizedBox(height: 16),
                  _guideStep(
                    stepNumber: '4',
                    title: 'Completion',
                    description: 'The puzzle is completed when all pipes are connected to the source without any loose, leaking ends.',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: TangibleButton(
                text: 'Got it',
                height: 44,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideStep({
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$stepNumber.',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.headingDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.subtext,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
