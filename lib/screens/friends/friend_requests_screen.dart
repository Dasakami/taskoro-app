// lib/screens/friends/friend_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/friends_model.dart';
import '../../providers/friends_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({Key? key}) : super(key: key);

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Загрузить заявки после первого рендера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().fetchFriendRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _acceptRequest(FriendRequest req) async {
    try {
      await context.read<FriendsProvider>().acceptFriendRequest(req.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заявка принята!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка при принятии заявки'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _declineRequest(FriendRequest req) async {
    // теперь возвращает bool
    final success =
    await context.read<FriendsProvider>().declineFriendRequest(req.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Заявка отклонена' : 'Не удалось отклонить заявку',
          ),
          backgroundColor: success ? Colors.orange : Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelRequest(FriendRequest req) async {
    final success =
    await context.read<FriendsProvider>().cancelFriendRequest(req.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Заявка отменена' : 'Ошибка отмены заявки',
          ),
          backgroundColor: success ? Colors.orange : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Заявки в друзья'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentPrimary,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Входящие'),
            Tab(text: 'Исходящие'),
          ],
        ),
      ),
      body: Consumer<FriendsProvider>(
        builder: (_, provider, __) {
          if (provider.isLoadingRequests) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsList(provider.receivedRequests, isReceived: true),
              _buildRequestsList(provider.sentRequests,     isReceived: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(List<FriendRequest> list,
      {required bool isReceived}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isReceived ? Icons.inbox : Icons.outbox,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isReceived
                  ? 'Нет входящих заявок'
                  : 'Нет исходящих заявок',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<FriendsProvider>().fetchFriendRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final req = list[i];
          return MagicCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accentPrimary,
                backgroundImage: req.avatarUrl != null
                    ? NetworkImage(req.avatarUrl!)
                    : null,
                child: req.avatarUrl == null
                    ? Text(
                  req.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              title: Text(
                req.username,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Уровень ${req.level}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              trailing: isReceived
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _acceptRequest(req),
                    icon: const Icon(Icons.check_circle),
                    color: Colors.green,
                    tooltip: 'Принять',
                  ),
                  IconButton(
                    onPressed: () => _declineRequest(req),
                    icon: const Icon(Icons.cancel),
                    color: Colors.red,
                    tooltip: 'Отклонить',
                  ),
                ],
              )
                  : IconButton(
                onPressed: () => _cancelRequest(req),
                icon: const Icon(Icons.close),
                color: Colors.orange,
                tooltip: 'Отменить заявку',
              ),
            ),
          );
        },
      ),
    );
  }
}
