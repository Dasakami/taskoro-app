import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/screens/duels/waiting_duels_screen.dart';
import '../../models/duel_model.dart';
import '../../providers/duel_provider.dart';
import '../../providers/user_provider.dart'; // чтобы получить токен
import '../../theme/app_theme.dart';
import 'duel_detail_screen.dart'; // импорт экрана деталей

class DuelsScreen extends StatefulWidget {
  const DuelsScreen({super.key});

  @override
  State<DuelsScreen> createState() => _DuelsScreenState();
}

class _DuelsScreenState extends State<DuelsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadDuels();
      _isInit = false;
    }
  }

  Future<void> _loadDuels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final accessToken = userProvider.accessToken;

      if (accessToken != null) {
        await Provider.of<DuelProvider>(context, listen: false)
            .fetchDuels(accessToken);
        // Убираем fetchWaitingDuels — больше не нужен
      } else {
        throw Exception('Нет токена доступа');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final duelProvider = Provider.of<DuelProvider>(context);

    final rejectedDuels = duelProvider.duels.where((d) => d.status == 'declined').toList();
    final activeDuels = duelProvider.duels.where((d) => d.status == 'active').toList();
    final finishedDuels = duelProvider.duels.where((d) => d.status == 'completed').toList();
    final pendingDuels = duelProvider.duels.where((d) => d.status == 'pending').toList(); // Ожидающие дуэли

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дуэли'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Отклонённые'),
            Tab(text: 'Активные'),
            Tab(text: 'Завершённые'),
            Tab(text: 'Ожидание'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ошибка: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDuels,
                child: const Text('Попробовать снова'),
              ),
            ],
          ),
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          DuelListView(duels: rejectedDuels, emptyText: 'Нет отклонённых дуэлей'),
          DuelListView(duels: activeDuels, emptyText: 'Нет активных дуэлей'),
          DuelListView(duels: finishedDuels, emptyText: 'Нет завершённых дуэлей'),
          DuelListView(duels: pendingDuels, emptyText: 'Нет ожидающих дуэлей'), // Здесь теперь обычный список
        ],
      ),
    );
  }
}

class DuelListView extends StatelessWidget {
  final List<DuelModel> duels;
  final String emptyText;

  const DuelListView({super.key, required this.duels, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (duels.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duels.length,
      itemBuilder: (context, index) {
        final duel = duels[index];
        return DuelCard(duel: duel);
      },
    );
  }
}

class DuelCard extends StatelessWidget {
  final DuelModel duel;

  const DuelCard({super.key, required this.duel});

  @override
  Widget build(BuildContext context) {
    final opponent = duel.opponent;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: (opponent.avatar != null && opponent.avatar.isNotEmpty)
                  ? NetworkImage(opponent.avatar)
                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
              radius: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opponent.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Статус: ${duel.status}'),
                  Text('Ставка монет: ${duel.coinsStake}'),
                  Text(
                    'Создано: ${duel.createdAt.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DuelDetailScreen(duel: duel),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
