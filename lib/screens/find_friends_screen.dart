import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/friends_model.dart';
import '../providers/friends_provider.dart';
import '../theme/app_theme.dart';

class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Friend> _results = [];
  String? _error;

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await context.read<FriendsProvider>().searchUsers(query);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = 'Ошибка при поиске.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendRequest(int userId) async {
    try {
      await context.read<FriendsProvider>().sendFriendRequest(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запрос отправлен')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при отправке запроса')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Найти друзей')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Введите имя пользователя',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchUsers(_searchController.text),
                ),
              ),
              onSubmitted: _searchUsers,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_results.isEmpty)
                const Text('Пользователи не найдены')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final user = _results[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(user.username ?? 'Неизвестно'),
                        trailing: ElevatedButton(
                          onPressed: () => _sendRequest(user.id),
                          child: const Text('Добавить'),
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
