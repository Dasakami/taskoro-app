import 'package:flutter/material.dart';
import 'package:taskoro/theme/app_theme.dart';

enum ToastType { success, info, warning, error }

class ToastUtils {
  static void showToast(
      BuildContext context, {
        required String message,
        ToastType type = ToastType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    final overlay = Overlay.of(context);

    final colorMap = {
      ToastType.success: AppColors.success,
      ToastType.info: AppColors.accentPrimary,
      ToastType.warning: AppColors.warning,
      ToastType.error: AppColors.error,
    };

    final bgColorMap = {
      ToastType.success: AppColors.success.withOpacity(0.1),
      ToastType.info: AppColors.accentPrimary.withOpacity(0.1),
      ToastType.warning: AppColors.warning.withOpacity(0.1),
      ToastType.error: AppColors.error.withOpacity(0.1),
    };

    final iconMap = {
      ToastType.success: Icons.check_circle_outline,
      ToastType.info: Icons.info_outline,
      ToastType.warning: Icons.warning_amber_outlined,
      ToastType.error: Icons.error_outline,
    };

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColorMap[type],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorMap[type]!.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    iconMap[type],
                    color: colorMap[type],
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: colorMap[type],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      entry.remove();
    });
  }
}