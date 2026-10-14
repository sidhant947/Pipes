import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';
import 'package:pipes/ui/core/widgets/pipe_widget.dart';
import 'package:pipes/ui/core/widgets/tangible_button.dart';
import 'package:pipes/ui/features/game/view_models/game_view_model.dart';
import 'package:pipes/ui/providers.dart';
import 'package:url_launcher/url_launcher.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({
    super.key,
    required this.levelNumber,
    this.isRandom = false,
    this.randomDifficulty = 'Easy',
  });

  final int levelNumber;
  final bool isRandom;
  final String randomDifficulty;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _shockwaveController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _shockwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.microtask(() {
      if (!mounted) return;
      if (widget.isRandom) {
        ref
            .read(gameViewModelProvider.notifier)
            .loadRandomLevel(widget.randomDifficulty);
      } else {
        ref.read(gameViewModelProvider.notifier).loadLevel(widget.levelNumber);
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _shockwaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final state = ref.watch(gameViewModelProvider);
    AppColors.currentTheme = settings.theme;

    ref.listen<GameViewModelState>(gameViewModelProvider, (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        _onLevelComplete(next);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        iconSize: 18,
                        onTap: () => Navigator.pop(context),
                      ),
                      Text(
                        state.isRandomMode
                            ? (state.randomDifficulty ??
                                  widget.randomDifficulty)
                            : 'Level ${widget.levelNumber}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingDark,
                        ),
                      ),
                      _circleButton(
                        icon: Icons.refresh_rounded,
                        iconSize: 20,
                        onTap: () => ref
                            .read(gameViewModelProvider.notifier)
                            .resetLevel(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      (state.isLoading ||
                          (!state.isRandomMode &&
                              (state.level == null ||
                                  state.level!.levelNumber !=
                                      widget.levelNumber)))
                      ? const Center(child: CircularProgressIndicator())
                      : state.error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(gameViewModelProvider.notifier)
                                    .resetLevel(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _buildGame(state),
                ),
              ],
            ),
            ConfettiExplosion(trigger: state.isComplete),
          ],
        ),
      ),
    );
  }

  Widget _buildGame(GameViewModelState state) {
    final settings = ref.watch(settingsProvider);
    final level = state.level;
    if (level == null || state.board.isEmpty) return const SizedBox.shrink();
    if (!state.isRandomMode && level.levelNumber != widget.levelNumber) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat('Moves', '${state.moveCount}', Icons.trending_up_rounded),
              _verticalDivider(),
              _stat(
                'Time',
                _formatTime(state.elapsedSeconds),
                Icons.timer_outlined,
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _shakeController,
                    _shockwaveController,
                  ]),
                  builder: (context, child) {
                    final t = _shakeController.value;
                    final factor = 1.0 - t;
                    final shakeX = math.sin(t * math.pi * 8) * 4.5 * factor;
                    final shakeY = math.cos(t * math.pi * 6) * 3.0 * factor;
                    return Transform.translate(
                      offset: Offset(shakeX, shakeY),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          child!,
                          if (_shockwaveController.value > 0.0 &&
                              _shockwaveController.value < 1.0)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: VictoryShockwavePainter(
                                    progress: _shockwaveController.value,
                                    gridSize: level.gridSize,
                                    sourceRow: level.sourceRow,
                                    sourceCol: level.sourceCol,
                                    waveColor: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  child: PipeGameBoard(
                    key: ValueKey(
                      'board_${state.isRandomMode ? (state.randomSeed ?? 0) : level.levelNumber}',
                    ),
                    levelId: state.isRandomMode
                        ? (state.randomSeed ?? 0)
                        : level.levelNumber,
                    gridSize: level.gridSize,
                    board: state.board,
                    waterFlow: state.waterFlow,
                    sourceRow: level.sourceRow,
                    sourceCol: level.sourceCol,
                    hintCell: state.hintCell,
                    bgColor: AppColors.bg,
                    onTileTap: state.isComplete
                        ? null
                        : (r, c) {
                            ref
                                .read(gameViewModelProvider.notifier)
                                .rotateTile(r, c);
                          },
                  ),
                ),
              ),
            ),
          ),
        ),
        if (state.isComplete)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 24 * (1.0 - value)),
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: _buildCompletionBottomBar(state),
          )
        else ...[
          if (settings.isHintEnabled) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: !state.isComplete
                  ? () => ref.read(gameViewModelProvider.notifier).revealHint()
                  : null,
              child: Opacity(
                opacity: !state.isComplete ? 1.0 : 0.35,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.headingDark.withValues(alpha: 0.08),
                        offset: const Offset(0, 3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lightbulb_rounded,
                        color: Color(0xFFFFCC00),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hint',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Tap any pipe to rotate clockwise',
              style: TextStyle(fontSize: 12, color: AppColors.subtext),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.35,
        child: Container(
          padding: const EdgeInsets.all(12),
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
          child: Icon(icon, size: iconSize, color: AppColors.headingDark),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _stat(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.headingDark),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.headingDark,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.subtext,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 32, color: AppColors.gridLines);
  }

  Future<void> _onLevelComplete(GameViewModelState state) async {
    _shakeController.forward(from: 0.0);
    _shockwaveController.forward(from: 0.0);
    HapticFeedback.heavyImpact();
    await ref.read(gameViewModelProvider.notifier).completeLevel();
  }

  Widget _buildCompletionBottomBar(GameViewModelState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.headingDark,
            ),
          ),
          const SizedBox(height: 10),
          TangibleButton(
            text: state.isRandomMode ? 'Play Again' : 'Next Level',
            height: 42,
            backgroundColor: AppColors.primary,
            textColor: AppColors.headingDark,
            borderColor: AppColors.border,
            onPressed: () {
              final notifier = ref.read(gameViewModelProvider.notifier);
              if (state.isRandomMode) {
                notifier.loadRandomLevel(state.randomDifficulty ?? 'Easy');
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GameView(levelNumber: widget.levelNumber + 1),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          TangibleButton(
            text: 'Home',
            isSecondary: true,
            height: 42,
            backgroundColor: AppColors.surface,
            textColor: AppColors.headingDark,
            borderColor: AppColors.border,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
          TangibleButton(
            text: 'Buy me a Coffee',
            isSecondary: true,
            height: 42,
            backgroundColor: AppColors.surface,
            textColor: AppColors.headingDark,
            borderColor: AppColors.border,
            onPressed: _openKoFiUrl,
          ),
        ],
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
}

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double rotation;
  double rotationSpeed;
  Color color;
  bool isCircle;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.isCircle,
  });

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vy += 300.0 * dt;
    vx *= math.pow(0.98, dt * 60);
    vy *= math.pow(0.98, dt * 60);
    rotation += rotationSpeed * dt;
  }
}

class ConfettiExplosion extends StatefulWidget {
  final bool trigger;
  const ConfettiExplosion({super.key, required this.trigger});

  @override
  State<ConfettiExplosion> createState() => _ConfettiExplosionState();
}

class _ConfettiExplosionState extends State<ConfettiExplosion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(_tick);

    if (widget.trigger) {
      _burst();
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _burst();
    }
  }

  void _burst() {
    _particles.clear();
    final List<Color> colors = [
      Colors.white,
      Colors.white70,
      Colors.white54,
      Colors.white30,
      const Color(0xFF888888),
      const Color(0xFFCCCCCC),
      const Color(0xFF555555),
      const Color(0xFFAAAAAA),
    ];

    for (int i = 0; i < 80; i++) {
      final double angle = _random.nextDouble() * 2 * math.pi;
      final double speed = 150 + _random.nextDouble() * 250;
      _particles.add(
        ConfettiParticle(
          x: 0.5,
          y: 0.4,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 150,
          size: 6 + _random.nextDouble() * 8,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 10,
          color: colors[_random.nextInt(colors.length)],
          isCircle: _random.nextBool(),
        ),
      );
    }
    _controller.forward(from: 0.0);
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      for (final p in _particles) {
        p.update(0.016);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isAnimating) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: ConfettiPainter(particles: _particles),
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final double px = p.x * size.width;
      final double py = p.y * size.height;

      if (px < 0 || px > size.width || py > size.height) continue;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      final Paint paint = Paint()..color = p.color;

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

class VictoryShockwavePainter extends CustomPainter {
  VictoryShockwavePainter({
    required this.progress,
    required this.gridSize,
    required this.sourceRow,
    required this.sourceCol,
    required this.waveColor,
  });

  final double progress;
  final int gridSize;
  final int sourceRow;
  final int sourceCol;
  final Color waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;
    final cellSize = size.width / gridSize;
    final origin = Offset(
      (sourceCol + 0.5) * cellSize,
      (sourceRow + 0.5) * cellSize,
    );
    final maxRadius = size.width * 1.35;
    final currentRadius = maxRadius * progress;
    final ringWidth = cellSize * 0.75 * (1.0 - progress);
    final alpha = (0.55 * (1.0 - progress)).clamp(0.0, 1.0);

    final wavePaint = Paint()
      ..color = waveColor.withValues(alpha: alpha)
      ..strokeWidth = ringWidth
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawCircle(origin, currentRadius, wavePaint);
  }

  @override
  bool shouldRepaint(covariant VictoryShockwavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
