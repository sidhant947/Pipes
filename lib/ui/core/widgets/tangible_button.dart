import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';

class TangibleButton extends StatefulWidget {
  const TangibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.height = 48,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  State<TangibleButton> createState() => _TangibleButtonState();
}

class _TangibleButtonState extends State<TangibleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onPressed != null;
    final isPressedNow = _isPressed && isInteractive;

    final Color buttonBg = widget.backgroundColor ??
        (widget.isSecondary ? AppColors.surface : AppColors.primary);

    final Color textColor = widget.textColor ?? AppColors.headingDark;
    final Color borderColor = widget.borderColor ?? AppColors.border;

    final double shadowDepth = isPressedNow ? 1.0 : 4.0;
    final double translateY = isPressedNow ? 3.0 : 0.0;

    return GestureDetector(
      onTapDown: (_) {
        if (isInteractive) {
          setState(() => _isPressed = true);
          HapticFeedback.selectionClick();
        }
      },
      onTapUp: (_) {
        if (isInteractive) {
          setState(() => _isPressed = false);
          if (widget.onPressed != null) widget.onPressed!();
        }
      },
      onTapCancel: () {
        if (isInteractive) setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, translateY, 0),
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: buttonBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.headingDark.withValues(alpha: 0.12),
              offset: Offset(0, shadowDepth),
              blurRadius: isPressedNow ? 1.0 : 4.0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
