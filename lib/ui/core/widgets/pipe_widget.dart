import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';

class PipeRulesHelper {
  const PipeRulesHelper._();

  static int getBaseMask(int mask) {
    if (mask == 0) return 0;
    if (mask == 15) return 15;
    if (mask == 1 || mask == 2 || mask == 4 || mask == 8) return 1;
    if (mask == 5 || mask == 10) return 5;
    if (mask == 3 || mask == 6 || mask == 12 || mask == 9) return 3;
    if (mask == 7 || mask == 14 || mask == 13 || mask == 11) return 7;
    return mask;
  }

  static int getTargetRotation(int mask, int currentRot) {
    if (mask == 15 || mask == 0) return currentRot;
    if (mask == 5 || mask == 10) {
      final wantEven = (mask == 5);
      final isEven = (currentRot % 2 == 0);
      return isEven == wantEven ? currentRot : (currentRot + 1);
    }
    switch (mask) {
      case 1:
        return 0;
      case 2:
        return 1;
      case 4:
        return 2;
      case 8:
        return 3;
      case 3:
        return 0;
      case 6:
        return 1;
      case 12:
        return 2;
      case 9:
        return 3;
      case 7:
        return 0;
      case 14:
        return 1;
      case 13:
        return 2;
      case 11:
        return 3;
      default:
        return 0;
    }
  }
}

class PipePainter extends CustomPainter {
  PipePainter({
    required this.mask,
    required this.hasWater,
    required this.isSource,
    this.pipeColor,
    this.activeColor,
    this.bgColor,
  });

  final int mask;
  final bool hasWater;
  final bool isSource;
  final Color? pipeColor;
  final Color? activeColor;
  final Color? bgColor;

  static const Color defaultOffLight = Color(0xFFCBD5E1);
  static const Color defaultOffDark = Color(0xFF334155);
  static const Color defaultWaterColor = Color(0xFF0284C7);

  void _drawGeometry(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint bulbPaint,
    double cx,
    double cy,
    double bulbRadius,
  ) {
    int connectionCount = 0;
    if (mask & 1 != 0) connectionCount++;
    if (mask & 2 != 0) connectionCount++;
    if (mask & 4 != 0) connectionCount++;
    if (mask & 8 != 0) connectionCount++;

    if (connectionCount == 1) {
      Offset end = Offset(cx, cy);
      if (mask & 1 != 0) end = Offset(cx, 0);
      if (mask & 2 != 0) end = Offset(size.width, cy);
      if (mask & 4 != 0) end = Offset(cx, size.height);
      if (mask & 8 != 0) end = Offset(0, cy);

      canvas.drawLine(Offset(cx, cy), end, linePaint);
      canvas.drawCircle(Offset(cx, cy), bulbRadius, bulbPaint);
    } else if (connectionCount == 2) {
      if (mask == 5) {
        canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), linePaint);
      } else if (mask == 10) {
        canvas.drawLine(Offset(0, cy), Offset(size.width, cy), linePaint);
      } else {
        final path = Path();
        if (mask == 3) {
          path.arcTo(
            Rect.fromLTWH(cx, -cy, size.width, size.height),
            math.pi,
            -math.pi / 2,
            false,
          );
        } else if (mask == 6) {
          path.arcTo(
            Rect.fromLTWH(cx, cy, size.width, size.height),
            -math.pi / 2,
            -math.pi / 2,
            false,
          );
        } else if (mask == 12) {
          path.arcTo(
            Rect.fromLTWH(-cx, cy, size.width, size.height),
            0,
            -math.pi / 2,
            false,
          );
        } else if (mask == 9) {
          path.arcTo(
            Rect.fromLTWH(-cx, -cy, size.width, size.height),
            math.pi / 2,
            -math.pi / 2,
            false,
          );
        }
        canvas.drawPath(path, linePaint);
      }
    } else if (connectionCount == 3) {
      if (mask == 7) {
        canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), linePaint);
        canvas.drawLine(Offset(cx, cy), Offset(size.width, cy), linePaint);
      } else if (mask == 14) {
        canvas.drawLine(Offset(0, cy), Offset(size.width, cy), linePaint);
        canvas.drawLine(Offset(cx, cy), Offset(cx, size.height), linePaint);
      } else if (mask == 13) {
        canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), linePaint);
        canvas.drawLine(Offset(0, cy), Offset(cx, cy), linePaint);
      } else if (mask == 11) {
        canvas.drawLine(Offset(0, cy), Offset(size.width, cy), linePaint);
        canvas.drawLine(Offset(cx, 0), Offset(cx, cy), linePaint);
      }
    } else if (connectionCount == 4) {
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), linePaint);
      canvas.drawLine(Offset(0, cy), Offset(size.width, cy), linePaint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mask == 0) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final strokeWidth = size.width * 0.26;
    final bulbRadius = size.width * 0.22;

    final isDark = AppColors.currentTheme.isDark;
    final offColor = pipeColor ?? (isDark ? defaultOffDark : defaultOffLight);
    final onColor = activeColor ?? defaultWaterColor;
    final color = hasWater ? onColor : offColor;

    final pipePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.round;

    final bulbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    _drawGeometry(canvas, size, pipePaint, bulbPaint, cx, cy, bulbRadius);

    if (isSource) {
      _drawSourceBadge(canvas, cx, cy, strokeWidth, color, bgColor);
    }
  }

  void _drawSourceBadge(
    Canvas canvas,
    double cx,
    double cy,
    double strokeWidth,
    Color color,
    Color? bg,
  ) {
    final badgeRadius = strokeWidth * 0.95;

    final bgPaint = Paint()
      ..color = bg ?? Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), badgeRadius, bgPaint);

    final ringPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 0.18
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), badgeRadius, ringPaint);

    final corePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), badgeRadius * 0.45, corePaint);
  }

  @override
  bool shouldRepaint(covariant PipePainter oldDelegate) {
    return oldDelegate.mask != mask ||
        oldDelegate.hasWater != hasWater ||
        oldDelegate.isSource != isSource ||
        oldDelegate.pipeColor != pipeColor ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.bgColor != bgColor;
  }
}

class SourceBadgePainter extends CustomPainter {
  SourceBadgePainter({
    required this.hasWater,
    this.pipeColor,
    this.activeColor,
    this.bgColor,
    this.pulse = 0.0,
  });

  final bool hasWater;
  final Color? pipeColor;
  final Color? activeColor;
  final Color? bgColor;
  final double pulse;

  static const Color defaultOffLight = Color(0xFFCBD5E1);
  static const Color defaultOffDark = Color(0xFF334155);
  static const Color defaultWaterColor = Color(0xFF0284C7);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final strokeWidth = size.width * 0.26;
    final badgeRadius = strokeWidth * 0.95;

    final isDark = AppColors.currentTheme.isDark;
    final onColor = activeColor ?? defaultWaterColor;
    final offColor = pipeColor ?? (isDark ? defaultOffDark : defaultOffLight);
    final color = hasWater ? onColor : offColor;

    if (hasWater && pulse > 0.0) {
      final rippleRadius = badgeRadius * (1.0 + 0.45 * pulse);
      final rippleAlpha = (0.45 * (1.0 - pulse)).clamp(0.0, 1.0);
      final ripplePaint = Paint()
        ..color = onColor.withValues(alpha: rippleAlpha)
        ..strokeWidth = strokeWidth * 0.14
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(cx, cy), rippleRadius, ripplePaint);
    }

    final bgPaint = Paint()
      ..color = bgColor ?? Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), badgeRadius, bgPaint);

    final ringPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 0.18
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), badgeRadius, ringPaint);

    final coreRadius = badgeRadius * (0.45 + (hasWater ? 0.08 * math.sin(pulse * math.pi) : 0.0));
    final corePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), coreRadius, corePaint);
  }

  @override
  bool shouldRepaint(covariant SourceBadgePainter oldDelegate) {
    return oldDelegate.hasWater != hasWater ||
        oldDelegate.pipeColor != pipeColor ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.bgColor != bgColor ||
        oldDelegate.pulse != pulse;
  }
}

class PipeTile extends StatefulWidget {
  const PipeTile({
    super.key,
    required this.mask,
    required this.hasWater,
    required this.isSource,
    required this.size,
    this.isHint = false,
    this.onTap,
    this.pipeColor,
    this.activeColor,
    this.bgColor,
  });

  final int mask;
  final bool hasWater;
  final bool isSource;
  final double size;
  final bool isHint;
  final VoidCallback? onTap;
  final Color? pipeColor;
  final Color? activeColor;
  final Color? bgColor;

  @override
  State<PipeTile> createState() => _PipeTileState();
}

class _PipeTileState extends State<PipeTile> with TickerProviderStateMixin {
  late int _baseMask;
  late int _turns;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  AnimationController? _sourcePulseController;

  bool get _isInTest =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _baseMask = PipeRulesHelper.getBaseMask(widget.mask);
    _turns = PipeRulesHelper.getTargetRotation(widget.mask, 0);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.88)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_bounceController);

    if (widget.isSource) {
      _sourcePulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      );
      if (!_isInTest) {
        _sourcePulseController!.repeat();
      }
    }
  }

  @override
  void didUpdateWidget(covariant PipeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newBaseMask = PipeRulesHelper.getBaseMask(widget.mask);
    if (newBaseMask != _baseMask) {
      _baseMask = newBaseMask;
      _turns = PipeRulesHelper.getTargetRotation(widget.mask, 0);
    } else if (widget.mask != oldWidget.mask) {
      final currentRot = ((_turns % 4) + 4) % 4;
      final targetRot = PipeRulesHelper.getTargetRotation(widget.mask, currentRot);
      final diff = ((targetRot - currentRot) % 4 + 4) % 4;
      if (diff == 3) {
        _turns -= 1;
      } else if (diff != 0) {
        _turns += diff;
      }
      _bounceController.forward(from: 0.0);
    }

    if (widget.isSource && _sourcePulseController == null) {
      _sourcePulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      );
      if (!_isInTest) {
        _sourcePulseController!.repeat();
      }
    } else if (!widget.isSource && _sourcePulseController != null) {
      _sourcePulseController!.dispose();
      _sourcePulseController = null;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _sourcePulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap == null
          ? null
          : () {
              setState(() {
                _turns += 1;
              });
              _bounceController.forward(from: 0.0);
              widget.onTap!();
            },
      child: ScaleTransition(
        scale: _bounceAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isHint)
              Container(
                width: widget.size * 0.88,
                height: widget.size * 0.88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0284C7).withValues(alpha: 0.22),
                ),
              ),
            AnimatedRotation(
              turns: _turns * 0.25,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: PipePainter(
                  mask: _baseMask,
                  hasWater: widget.hasWater,
                  isSource: false,
                  pipeColor: widget.pipeColor,
                  activeColor: widget.activeColor,
                  bgColor: widget.bgColor,
                ),
              ),
            ),
            if (widget.isSource)
              _sourcePulseController != null
                  ? AnimatedBuilder(
                      animation: _sourcePulseController!,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: SourceBadgePainter(
                            hasWater: widget.hasWater,
                            pipeColor: widget.pipeColor,
                            activeColor: widget.activeColor,
                            bgColor: widget.bgColor,
                            pulse: _sourcePulseController!.value,
                          ),
                        );
                      },
                    )
                  : CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: SourceBadgePainter(
                        hasWater: widget.hasWater,
                        pipeColor: widget.pipeColor,
                        activeColor: widget.activeColor,
                        bgColor: widget.bgColor,
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}

class PipeGameBoard extends StatelessWidget {
  const PipeGameBoard({
    super.key,
    required this.gridSize,
    required this.board,
    required this.waterFlow,
    required this.sourceRow,
    required this.sourceCol,
    this.hintCell,
    this.onTileTap,
    this.levelId = 0,
    this.pipeColor,
    this.activeColor,
    this.bgColor,
  });

  final int gridSize;
  final List<List<int>> board;
  final List<List<bool>> waterFlow;
  final int sourceRow;
  final int sourceCol;
  final int? hintCell;
  final void Function(int r, int c)? onTileTap;
  final int levelId;
  final Color? pipeColor;
  final Color? activeColor;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = math.min(constraints.maxWidth, constraints.maxHeight);
        final cellSize = boardSize / gridSize;

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              for (int r = 0; r < gridSize; r++)
                for (int c = 0; c < gridSize; c++)
                  Positioned(
                    left: c * cellSize,
                    top: r * cellSize,
                    width: cellSize,
                    height: cellSize,
                    child: PipeTile(
                      key: ValueKey('pipe_${levelId}_${r}_$c'),
                      mask: board[r][c],
                      hasWater: waterFlow.isNotEmpty &&
                              r < waterFlow.length &&
                              c < waterFlow[r].length
                          ? waterFlow[r][c]
                          : false,
                      isSource: r == sourceRow && c == sourceCol,
                      size: cellSize,
                      isHint: hintCell == (r * gridSize + c),
                      onTap: onTileTap != null ? () => onTileTap!(r, c) : null,
                      pipeColor: pipeColor,
                      activeColor: activeColor,
                      bgColor: bgColor,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class PipeWidget extends StatelessWidget {
  const PipeWidget({
    super.key,
    required this.mask,
    this.hasWater = false,
    this.isSource = false,
    required this.size,
    this.pipeColor,
    this.activeColor,
    this.bgColor,
  });

  final int mask;
  final bool hasWater;
  final bool isSource;
  final double size;
  final Color? pipeColor;
  final Color? activeColor;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: PipePainter(
          mask: mask,
          hasWater: hasWater,
          isSource: isSource,
          pipeColor: pipeColor,
          activeColor: activeColor,
          bgColor: bgColor,
        ),
      ),
    );
  }
}

class PipeLogoWidget extends StatelessWidget {
  const PipeLogoWidget({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: PipeWidget(
        mask: 15,
        hasWater: true,
        isSource: true,
        size: size,
        bgColor: AppColors.surface,
      ),
    );
  }
}
