import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/screens/main/dashboard_screen.dart';
import 'package:taskoro/screens/tasks/tasks_screen.dart';
import 'package:taskoro/screens/tournaments_screen.dart';
import 'package:taskoro/screens/duels/duels_screen.dart';
import 'package:taskoro/widgets/app_drawer.dart';
import 'package:taskoro/widgets/animated_background.dart';

import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget _currentScreen = const DashboardScreen();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<UserProvider>(context, listen: false).refreshMainData();
  }

  @override
  void initState() {
    super.initState();
    didChangeDependencies();
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TasksScreen(),
    const TournamentsScreen(),
    const DuelsScreen(),
  ];

  final List<String> _titles = [
    'Главная',
    'Задачи',
    'Турниры',
    'Дуэли',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _currentScreen = _screens[index];
    });
  }

  void _navigateTo(Widget screen, String title) {
    Navigator.pop(context);
    setState(() {
      _currentScreen = screen;
      _selectedIndex = -1; // Чтобы ничто не выделялось в нижнем меню
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onNavigate: _navigateTo),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedIndex >= 0 && _selectedIndex < _titles.length
                            ? _titles[_selectedIndex]
                            : 'Daskoro',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(child: _currentScreen),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedIndex >= 0
          ? Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.accentPrimary,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Главная',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_box_outlined),
                activeIcon: Icon(Icons.check_box_rounded),
                label: 'Задачи',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined),
                activeIcon: Icon(Icons.emoji_events),
                label: 'Турниры',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_kabaddi_outlined),
                activeIcon: Icon(Icons.sports_kabaddi),
                label: 'Дуэли',
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }
}
