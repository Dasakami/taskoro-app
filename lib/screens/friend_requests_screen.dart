import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/magic_card.dart';
import '../providers/friends_provider.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => context.read<FriendsProvider>().fetchFriendRequests());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openUserProfile(BuildContext context, int userId) {
    // Тут пример перехода на экран профиля пользователя (создай экран UserProfileScreen)
    Navigator.pushNamed(context, '/user-profile', arguments: userId);
  }

  @override
  Widget build(BuildContext context) {
    final friendsProvider = context.watch<FriendsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Запросы в друзья'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentPrimary,
          tabs: const [
            Tab(text: 'Входящие'),
            Tab(text: 'Исходящие'),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: friendsProvider.isLoadingRequests
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Входящие запросы
          friendsProvider.receivedRequests.isEmpty
              ? const Center(child: Text('Нет входящих запросов'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friendsProvider.receivedRequests.length,
            itemBuilder: (context, index) {
              final request = friendsProvider.receivedRequests[index];
              return MagicCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accentPrimary,
                    backgroundImage: request.avatarUrl != null
                        ? NetworkImage(request.avatarUrl!)
                        : null,
                    child: request.avatarUrl == null
                        ? Text(
                      request.username[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                        : null,
                  ),
                  title: Text(request.username),
                  subtitle: Text('Уровень ${request.level}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Принять',
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await friendsProvider.acceptFriendRequest(request.id);
                        },
                      ),
                      IconButton(
                        tooltip: 'Отклонить',
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await friendsProvider.declineFriendRequest(request.id);
                        },
                      ),
                      IconButton(
                        tooltip: 'Просмотр профиля',
                        icon: const Icon(Icons.info_outline, color: Colors.blue),
                        onPressed: () {
                          _openUserProfile(context, request.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Исходящие запросы
          friendsProvider.sentRequests.isEmpty
              ? const Center(child: Text('Нет исходящих запросов'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friendsProvider.sentRequests.length,
            itemBuilder: (context, index) {
              final request = friendsProvider.sentRequests[index];
              return MagicCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accentSecondary,
                    backgroundImage: request.avatarUrl != null
                        ? NetworkImage(request.avatarUrl!)
                        : null,
                    child: request.avatarUrl == null
                        ? Text(
                      request.username[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                        : null,
                  ),
                  title: Text(request.username),
                  subtitle: Text('Уровень ${request.level}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Отменить запрос',
                        icon: const Icon(Icons.cancel, color: Colors.orange),
                        onPressed: () async {
                          await friendsProvider.cancelFriendRequest(request.id);
                        },
                      ),
                      IconButton(
                        tooltip: 'Просмотр профиля',
                        icon: const Icon(Icons.info_outline, color: Colors.blue),
                        onPressed: () {
                          _openUserProfile(context, request.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
