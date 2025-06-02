import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/friends_model.dart';
import '../../providers/friends_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/magic_card.dart';

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

  Future<void> _acceptRequest(FriendRequest request) async {
    final friendsProvider = Provider.of<FriendsProvider>(context, listen: false);
    await friendsProvider.acceptFriendRequest(request.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заявка принята!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _declineRequest(FriendRequest request) async {
    final friendsProvider = Provider.of<FriendsProvider>(context, listen: false);
    await friendsProvider.declineFriendRequest(request.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заявка отклонена'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _cancelRequest(FriendRequest request) async {
    final friendsProvider = Provider.of<FriendsProvider>(context, listen: false);
    final success = await friendsProvider.cancelFriendRequest(request.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Заявка отменена' : 'Ошибка отмены заявки'),
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
        builder: (context, friendsProvider, child) {
          if (friendsProvider.isLoadingRequests) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Входящие заявки
              _buildRequestsList(
                friendsProvider.receivedRequests,
                isReceived: true,
              ),
              // Исходящие заявки
              _buildRequestsList(
                friendsProvider.sentRequests,
                isReceived: false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(List<FriendRequest> requests, {required bool isReceived}) {
    if (requests.isEmpty) {
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
              isReceived ? 'Нет входящих заявок' : 'Нет исходящих заявок',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return MagicCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accentPrimary,
              backgroundImage: request.avatarUrl != null
                  ? NetworkImage(request.avatarUrl!)
                  : null,
              child: request.avatarUrl == null
                  ? Text(
                request.username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : null,
            ),
            title: Text(
              request.username,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Уровень ${request.level}',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: isReceived
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _acceptRequest(request),
                  icon: const Icon(Icons.check_circle),
                  color: Colors.green,
                  tooltip: 'Принять',
                ),
                IconButton(
                  onPressed: () => _declineRequest(request),
                  icon: const Icon(Icons.cancel),
                  color: Colors.red,
                  tooltip: 'Отклонить',
                ),
              ],
            )
                : IconButton(
              onPressed: () => _cancelRequest(request),
              icon: const Icon(Icons.close),
              color: Colors.orange,
              tooltip: 'Отменить заявку',
            ),
          ),
        );
      },
    );
  }
}