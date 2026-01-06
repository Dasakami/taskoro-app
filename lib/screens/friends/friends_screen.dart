import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/friends_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';
import '../../widgets/state_wrapper.dart';
import '../duels/task_stake_screen.dart';
import 'find_friends_screen.dart';
import 'friend_profile_screen.dart';
import 'friend_requests_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  static const routeName = '/friends';
  
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFriends();
    });
  }

  Future<void> _refreshFriends() async {
    final provider = Provider.of<FriendsProvider>(context, listen: false);
    await provider.fetchFriends();
    await provider.fetchFriendRequests();
  }

  void _navigateToFindFriends() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FindFriendsScreen()),
    );
    _refreshFriends();
  }

  void _navigateToRequests() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FriendRequestsScreen()),
    );
    _refreshFriends();
  }

  void _navigateToFriendProfile(friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendProfileScreen(friend: friend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Получаем ширину экрана для адаптивности
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<FriendsProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Заголовок и кнопки действий
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Друзья',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    // Кнопка заявок с бейджем
                    ElevatedButton.icon(
                      onPressed: _navigateToRequests,
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications, size: 16),
                          if (provider.receivedRequests.isNotEmpty)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${provider.receivedRequests.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      label: const Text('Заявки'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _navigateToFindFriends,
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Найти'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Обработка состояний загрузки и ошибок
                if (provider.isLoading && provider.friends.isEmpty)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.error != null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.error!,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshFriends,
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (provider.friends.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'У вас пока нет друзей',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Нажмите "Найти" чтобы добавить друзей',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Список друзей с адаптивной сеткой
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshFriends,
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: provider.friends.length,
                        itemBuilder: (context, index) {
                          final friend = provider.friends[index];
                          return MagicCard(
                            onTap: () => _navigateToFriendProfile(friend),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Аватар
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: AppColors.accentPrimary,
                                    backgroundImage: friend.avatarUrl != null
                                        ? NetworkImage(friend.avatarUrl!)
                                        : null,
                                    child: friend.avatarUrl == null
                                        ? Text(
                                      friend.username[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Имя
                                  Text(
                                    friend.username,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  
                                  // Уровень
                                  Text(
                                    'Уровень ${friend.level}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  
                                  // Опыт
                                  Text(
                                    'Опыт: ${friend.experience}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const Spacer(),
                                  
                                  // Кнопки действий
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.message),
                                        onPressed: () {
                                          AppSnackBar.showError(
                                            context,
                                            'Функция сообщений пока недоступна',
                                          );
                                        },
                                        color: AppColors.accentPrimary,
                                        iconSize: 18,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.sports_kabaddi),
                                        color: AppColors.accentSecondary,
                                        iconSize: 18,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                            TaskStakeScreen.routeName,
                                            arguments: friend.id,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}