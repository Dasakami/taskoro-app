import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/achievement_provider.dart';
import 'package:taskoro/providers/activity_log_provider.dart';
import 'package:taskoro/providers/duel_provider.dart';
import 'package:taskoro/providers/friends_provider.dart';
import 'package:taskoro/providers/notes_provider.dart';
import 'package:taskoro/providers/shop_provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:taskoro/providers/tasks_provider.dart';
import 'package:taskoro/screens/tasks/base_daily_screen.dart';
import 'package:taskoro/screens/tasks/base_habit_screen.dart';
import 'package:taskoro/screens/edit_profile_screen.dart';
import 'package:taskoro/screens/friends/friend_requests_screen.dart';
import 'package:taskoro/screens/main/main_screen.dart';
import 'package:taskoro/screens/main/login_screen.dart';
import 'package:taskoro/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ActivityLogProvider()),
        ChangeNotifierProvider(create: (_) => DuelProvider()),
        ChangeNotifierProxyProvider<UserProvider, TasksProvider>(
          create: (context) => TasksProvider(userProvider: context.read<UserProvider>()),
          update: (context, userProvider, previous) => TasksProvider(userProvider: userProvider),
        ),
        ChangeNotifierProxyProvider<UserProvider, NotesProvider>(
          create: (context) => NotesProvider(context.read<UserProvider>()),
          update: (_, userProvider, __) => NotesProvider(userProvider),
        ),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(
          create: (context) => ShopProvider(
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
        ),
        // Добавляем FriendsProvider, который зависит от UserProvider
        ChangeNotifierProvider(
          create: (context) => FriendsProvider(
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Taskoro — Игровая прокачка дисциплины и привычек',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        routes: {
          '/edit-profile': (context) => const ProfileEditScreen(),
          "/base-habits": (context) => const BaseHabitScreen(),
          "/base-daily": (context) => const BaseDailyScreen(),
          "/friend-requests": (context) => const FriendRequestsScreen(),
          // добавь другие экраны здесь
        },
        home: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return userProvider.isAuthenticated
                ? const MainScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
