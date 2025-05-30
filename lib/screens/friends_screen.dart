import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/screens/friend_requests_screen.dart';

import '../providers/friends_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/magic_card.dart';
import 'find_friends_screen.dart';  // Импорт экрана поиска друзей

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    // Загрузка друзей при открытии
    Future.microtask(() => context.read<FriendsProvider>().fetchFriends());
  }

  @override
  Widget build(BuildContext context) {
    final friendsProvider = context.watch<FriendsProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Друзья',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FindFriendsScreen()),
                    );
                    // Обновить список друзей после возврата с экрана поиска
                    context.read<FriendsProvider>().fetchFriends();
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Найти друзей'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentSecondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FriendRequestsScreen()),
                    );
                    // Обновить список друзей после возврата с экрана поиска
                    context.read<FriendsProvider>().fetchFriends();
                  },
                  icon: const Icon(Icons.request_page),
                  label: const Text('Заявки'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (friendsProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (friendsProvider.error != null)
              Center(child: Text(friendsProvider.error!))
            else if (friendsProvider.friends.isEmpty)
                const Center(child: Text('У вас пока нет друзей'))
              else
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: friendsProvider.friends.length,
                    itemBuilder: (context, index) {
                      final friend = friendsProvider.friends[index];
                      return MagicCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.accentPrimary,
                                backgroundImage: friend.avatarUrl != null
                                    ? NetworkImage(friend.avatarUrl!)
                                    : null,
                                child: friend.avatarUrl == null
                                    ? Text(
                                  friend.username[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                  ),
                                )
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                friend.username,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Уровень ${friend.level}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Опыт: ${friend.experience}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.message),
                                    onPressed: () {
                                      // Открыть чат с другом
                                    },
                                    color: AppColors.accentPrimary,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.sports_kabaddi),
                                    onPressed: () {
                                      // Вызов дуэли или другая активность
                                    },
                                    color: AppColors.accentSecondary,
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
          ],
        ),
      ),
    );
  }
}
