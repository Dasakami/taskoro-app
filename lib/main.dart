import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/achievement_provider.dart';
import 'package:taskoro/providers/friends_provider.dart';
import 'package:taskoro/providers/notes_provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:taskoro/providers/tasks_provider.dart';
import 'package:taskoro/screens/base_daily_screen.dart';
import 'package:taskoro/screens/base_habit_screen.dart';
import 'package:taskoro/screens/edit_profile_screen.dart';
import 'package:taskoro/screens/friend_requests_screen.dart';
import 'package:taskoro/screens/main_screen.dart';
import 'package:taskoro/screens/login_screen.dart';
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
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProxyProvider<UserProvider, NotesProvider>(
          create: (context) => NotesProvider(context.read<UserProvider>()),
          update: (_, userProvider, __) => NotesProvider(userProvider),
        ),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        // Добавляем FriendsProvider, который зависит от UserProvider
        ChangeNotifierProxyProvider<UserProvider, FriendsProvider>(
          create: (context) => FriendsProvider(context.read<UserProvider>()),
          update: (context, userProvider, friendsProvider) {
            friendsProvider!.userProvider = userProvider;
            return friendsProvider;
          },
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
