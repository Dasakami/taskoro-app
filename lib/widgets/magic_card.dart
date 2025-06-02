import 'package:flutter/material.dart';
import 'package:taskoro/theme/app_theme.dart';

class MagicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final bool glowEffect;
  final bool useGradientBorder;
  final Color? color;  // новый параметр для цвета фона
  final VoidCallback? onTap;

  const MagicCard({
    super.key,
    required this.child,
    this.margin,
    this.borderColor,
    this.glowEffect = true,
    this.useGradientBorder = false,
    this.color,  // добавляем в конструктор
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color ?? AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: useGradientBorder
            ? null
            : Border.all(
          color: borderColor ?? AppColors.border,
          width: 1,
        ),
        boxShadow: glowEffect
            ? [
          BoxShadow(
            color: AppColors.accentPrimary.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ]
            : null,
      ),
      child: useGradientBorder
          ? _GradientBorderCard(child: child, innerColor: color ?? AppColors.backgroundSecondary)
          : ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _GradientBorderCard extends StatelessWidget {
  final Widget child;
  final Color innerColor; // цвет внутренней области

  const _GradientBorderCard({
    required this.child,
    required this.innerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientPrimary,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Container(
            color: innerColor,
            child: child,
          ),
        ),
      ),
    );
  }
}
