import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/friends_model.dart';
import '../../providers/friends_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';

class FriendProfileScreen extends StatelessWidget {
  final Friend friend;

  const FriendProfileScreen({
    super.key,
    required this.friend,
  });

  Future<void> _removeFriend(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('Удалить из друзей'),
        content: Text('Вы уверены, что хотите удалить ${friend.username} из друзей?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final friendsProvider = Provider.of<FriendsProvider>(context, listen: false);
      final success = await friendsProvider.removeFriend(friend.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Друг удален из списка'
                  : 'Ошибка удаления друга',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text(friend.username),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'remove') {
                _removeFriend(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Удалить из друзей'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Профиль друга
            MagicCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.accentPrimary,
                      backgroundImage: friend.avatarUrl != null
                          ? NetworkImage(friend.avatarUrl!)
                          : null,
                      child: friend.avatarUrl == null
                          ? Text(
                        friend.username[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      friend.username,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Уровень ${friend.level}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accentPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Опыт: ${friend.experience}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Действия
            MagicCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Действия',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.message,
                          label: 'Сообщение',
                          color: AppColors.accentPrimary,
                          onPressed: () {
                            // TODO: Открыть чат
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Функция сообщений пока недоступна'),
                              ),
                            );
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.sports_kabaddi,
                          label: 'Дуэль',
                          color: AppColors.accentSecondary,
                          onPressed: () {
                            // TODO: Вызвать на дуэль
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Функция дуэлей пока недоступна'),
                              ),
                            );
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.person_remove,
                          label: 'Удалить',
                          color: Colors.red,
                          onPressed: () => _removeFriend(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          radius: 30,
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}