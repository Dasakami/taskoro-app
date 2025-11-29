import 'package:flutter/material.dart';
import 'package:taskoro/theme/app_theme.dart';

/// Универсальный виджет для обработки состояний загрузки, ошибок и пустых данных
class StateWrapper extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final bool isEmpty;
  final Widget child;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final IconData emptyIcon;
  final Widget? emptyAction;
  
  const StateWrapper({
    super.key,
    required this.isLoading,
    this.error,
    required this.isEmpty,
    required this.child,
    this.onRetry,
    this.emptyMessage = 'Нет данных',
    this.emptyIcon = Icons.inbox,
    this.emptyAction,
  });

  @override
  Widget build(BuildContext context) {
    // Показываем загрузку
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accentPrimary,
        ),
      );
    }
    
    // Показываем ошибку
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    
    // Показываем пустое состояние
    if (isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emptyIcon,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (emptyAction != null) ...[
                const SizedBox(height: 24),
                emptyAction!,
              ],
            ],
          ),
        ),
      );
    }
    
    // Показываем контент
    return child;
  }
}

/// Виджет для обработки async операций
class AsyncBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final String errorMessage;
  final VoidCallback? onRetry;
  
  const AsyncBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.errorMessage = 'Ошибка загрузки данных',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.accentPrimary,
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторить'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        
        if (!snapshot.hasData) {
          return Center(
            child: Text(
              'Нет данных',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        
        return builder(context, snapshot.data as T);
      },
    );
  }
}

/// Кастомный SnackBar для уведомлений
class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  static void showError(BuildContext context, String message) {
    show(context, message: message, isError: true);
  }
  
  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, isError: false);
  }
}

/// Диалог подтверждения
class ConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Да',
    String cancelText = 'Отмена',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? AppColors.error : AppColors.accentPrimary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}