// screens/duels_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/screens/friends/friends_screen.dart';

import '../../models/duel_model.dart';
import '../../providers/duel_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import 'create_duel_screen.dart';
import 'duel_detail_screen.dart';


class DuelsScreen extends StatefulWidget {
  static const routeName = '/duels';

  const DuelsScreen({super.key});
  @override _DuelsScreenState createState() => _DuelsScreenState();
}

class _DuelsScreenState extends State<DuelsScreen> {
  late Future _load;
  @override
  void initState() {
    super.initState();
    final token = context.read<UserProvider>().accessToken;
    _load = context.read<DuelProvider>().fetchDuels(token!);
  }

  @override
  Widget build(BuildContext ctx) {
    final prov = ctx.watch<DuelProvider>();
    final token = ctx.read<UserProvider>().accessToken;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Дуэли'),
          bottom: TabBar(tabs: const [
            Tab(text: 'Ожидание'),
            Tab(text: 'В игре'),
            Tab(text: 'Отклонено'),
            Tab(text: 'Завершено'),
          ]),
        ),
        body: FutureBuilder(
          future: _load,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Ошибка: ${snap.error}'));
            }

            return TabBarView(children: [
              _buildList(prov.pendingDuels, token!),
              _buildList(prov.activeDuels, token!),
              _buildList(prov.declinedDuels, token!),
              _buildList(prov.completedDuels, token!),
            ]);
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.person_add),
          onPressed: () => Navigator.pushNamed(ctx, FriendsScreen.routeName),
        ),
      ),
    );
  }

  Widget _buildList(List<DuelModel> list, String token) {
    if (list.isEmpty) {
      return Center(child: Text('Пусто', style: AppTheme.darkTheme.textTheme.bodyLarge));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (c, i) {
        final d = list[i];
        return Card(
          shape: AppTheme.darkTheme.cardTheme.shape,
          color: AppTheme.darkTheme.cardTheme.color,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text('${d.challenger.username} → ${d.opponent.username}',
                style: AppTheme.darkTheme.textTheme.bodyLarge),
            subtitle: Text('Ставка: ${d.coinsStake}  •  Статус: ${d.status}',
                style: AppTheme.darkTheme.textTheme.bodyMedium),
            trailing: Icon(Icons.chevron_right, color: AppColors.accentPrimary),
            onTap: () {
              Navigator.pushNamed(
                context,
                DuelDetailScreen.routeName,
                arguments: d,
              );
            },
          ),
        );
      },
    );
  }
}
