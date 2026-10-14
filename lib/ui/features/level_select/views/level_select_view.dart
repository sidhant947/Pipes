import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';
import 'package:pipes/ui/features/game/views/game_view.dart';
import 'package:pipes/ui/providers.dart';

class LevelSelectView extends ConsumerStatefulWidget {
  const LevelSelectView({super.key});

  @override
  ConsumerState<LevelSelectView> createState() => _LevelSelectViewState();
}

class _LevelSelectViewState extends ConsumerState<LevelSelectView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final state = ref.watch(homeViewModelProvider);
    AppColors.currentTheme = settings.theme;
    final highestCompleted = state.progress?.highestLevelCompleted ?? 0;
    final unlockedLevel = math.max(highestCompleted + 1, state.progress?.currentLevel ?? 1);
    final int totalLevelsToShow = unlockedLevel + 10;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.headingDark.withValues(alpha: 0.08),
                            offset: const Offset(0, 3),
                            blurRadius: 4,
                          ),
                        ],
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
                        'Levels',
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
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 24, 28, 28),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: totalLevelsToShow,
                itemBuilder: (context, index) {
                  final levelNumber = index + 1;
                  final isCompleted = levelNumber <= highestCompleted;
                  final isCurrent = levelNumber == unlockedLevel;
                  final isLocked = levelNumber > unlockedLevel;

                  return _buildLevelCard(
                    context,
                    levelNumber: levelNumber,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isLocked: isLocked,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required int levelNumber,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
  }) {
    Color cardBg = AppColors.surface;
    Color textColor = AppColors.headingDark;
    Color borderColor = AppColors.border;
    Widget content;
    bool isClickable = !isLocked;

    if (isCompleted) {
      cardBg = const Color(0xFF10B981);
      textColor = Colors.white;
      borderColor = const Color(0xFF059669);
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: Colors.white,
          ),
          SizedBox(height: 2),
        ],
      );
    } else if (isCurrent) {
      cardBg = AppColors.primary;
      textColor = AppColors.headingDark;
      borderColor = AppColors.accent;
      content = const SizedBox.shrink();
    } else {
      cardBg = AppColors.surface.withValues(alpha: 0.5);
      textColor = AppColors.subtext;
      borderColor = AppColors.border.withValues(alpha: 0.4);
      content = const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: isClickable
          ? () async {
              ref.read(levelGeneratorProvider).pregenerateAround(levelNumber, range: 1);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameView(levelNumber: levelNumber),
                ),
              );
              ref.read(homeViewModelProvider.notifier).loadProgress();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isCurrent ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.headingDark.withValues(alpha: 0.06),
              offset: const Offset(0, 3),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLocked
            ? Icon(
                Icons.lock_rounded,
                size: 20,
                color: AppColors.subtext.withValues(alpha: 0.6),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$levelNumber',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (isCompleted) content,
                ],
              ),
      ),
    );
  }
}
