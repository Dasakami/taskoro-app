import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onClose;

  const Sidebar({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF1C1C1E),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          // Аватар и уровень
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              'https://your-server.com/media/avatar.jpg',
            ),
          ),
          const SizedBox(height: 10),
          const Text('Dan Dasakami', style: TextStyle(fontSize: 20)),
          const Text('Уровень: 1', style: TextStyle(color: Colors.grey)),

          const Divider(height: 30),

          // Навигация
          Expanded(
            child: ListView(
              children: [
                sidebarItem(Icons.home, 'Главная'),
                sidebarItem(Icons.check_circle, 'Задачи'),
                sidebarItem(Icons.emoji_events, 'Турнир'),
                sidebarItem(Icons.sports, 'Дуэль'),
                sidebarItem(Icons.group, 'Друзья'),
                sidebarItem(Icons.workspace_premium, 'Достижения'),
                sidebarItem(Icons.shopping_cart, 'Магазин'),
                sidebarItem(Icons.history, 'История'),
                sidebarItem(Icons.note, 'Заметки'),
              ],
            ),
          ),

          const Divider(height: 20),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget sidebarItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: () {},
    );
  }
}
