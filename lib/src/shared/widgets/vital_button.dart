import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum VitalButtonType { primary, secondary, ghost, danger }

class VitalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VitalButtonType type;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const VitalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = VitalButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;
    double elevation = 0;

    switch (type) {
      case VitalButtonType.primary:
        backgroundColor = isDark ? AppColors.primaryDark : AppColors.primary;
        foregroundColor = Colors.white;
        elevation = 2;
        break;
      case VitalButtonType.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.primaryDark : AppColors.primary;
        borderSide = BorderSide(color: foregroundColor, width: 1.5);
        break;
      case VitalButtonType.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        break;
      case VitalButtonType.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      side: borderSide,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: AppTextStyles.button,
    );

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (!isLoading && icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    if (isFullWidth) {
      child = SizedBox(width: double.infinity, child: child);
    }

    // Usamos ElevatedButton para todos para mantener uniformidad en forma/animación
    // Ajustamos colores para simular outline/ghost
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: child,
    );
  }
}
