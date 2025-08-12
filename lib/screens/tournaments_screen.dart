import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:taskoro/screens/tournament_detail.dart';

import '../providers/tournaments_provider.dart';
import '../theme/app_theme.dart';

class TournamentsScreen extends StatefulWidget {
  static const routeName = '/tournaments';

  const TournamentsScreen({super.key});
  @override
  _TournamentsScreenState createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = Provider.of<TournamentsProvider>(
      context,
      listen: false,
    ).fetchTournaments();
  }

  Widget _buildList(List list) {
    if (list.isEmpty) {
      return Center(
        child: Text('Пусто', style: AppTheme.darkTheme.textTheme.bodyLarge),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final t = list[i];
        final date = DateFormat('dd.MM.yyyy').format(t.startDate);
        return Card(
          shape: AppTheme.darkTheme.cardTheme.shape,
          color: AppTheme.darkTheme.cardTheme.color,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(t.title,
                style: AppTheme.darkTheme.textTheme.displaySmall),
            subtitle: Text(
              '$date\n${t.description}',
              style: AppTheme.darkTheme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: true,
            trailing: Icon(Icons.chevron_right,
                color: AppColors.accentPrimary),
            onTap: () {
              Navigator.of(context).pushNamed(
                TournamentDetailScreen.routeName,
                arguments: t,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TournamentsProvider>(context);

    // ВАЖНО: DefaultTabController оборачивает Scaffold
    return DefaultTabController(
      length: 3, // количество вкладок
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Турниры'),
          bottom: const TabBar(
            indicatorColor: AppColors.accentPrimary,
            tabs: [
              Tab(text: 'Активные'),
              Tab(text: 'Предстоящие'),
              Tab(text: 'Прошедшие'),
            ],
          ),
        ),
        body: FutureBuilder(
          future: _fetchFuture,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Text('Ошибка загрузки: ${snap.error}',
                    style:
                    AppTheme.darkTheme.textTheme.bodyLarge),
              );
            }
            // Данные получены – рисуем TabBarView
            return TabBarView(
              children: [
                _buildList(prov.activeTournaments),
                _buildList(prov.upcomingTournaments),
                _buildList(prov.pastTournaments),
              ],
            );
          },
        ),
      ),
    );
  }
}