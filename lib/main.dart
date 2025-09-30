import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/achievement_provider.dart';
import 'package:taskoro/providers/activity_log_provider.dart';
import 'package:taskoro/providers/base_daily_provider.dart';
import 'package:taskoro/providers/base_habit_provider.dart';
import 'package:taskoro/providers/base_task_provider.dart';
import 'package:taskoro/providers/duel_provider.dart';
import 'package:taskoro/providers/friends_provider.dart';
import 'package:taskoro/providers/notes_provider.dart';
import 'package:taskoro/providers/shop_provider.dart';
import 'package:taskoro/providers/tournaments_provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:taskoro/providers/tasks_provider.dart';
import 'package:taskoro/screens/duels/create_duel_screen.dart';
import 'package:taskoro/screens/duels/duel_detail_screen.dart';
import 'package:taskoro/screens/duels/duels_screen.dart';
import 'package:taskoro/screens/duels/task_stake_screen.dart';
import 'package:taskoro/screens/friends/friends_screen.dart';
import 'package:taskoro/screens/leaderboard_screen.dart';
import 'package:taskoro/screens/tasks/base_daily_detail_screen.dart';
import 'package:taskoro/screens/tasks/base_daily_screen.dart';
import 'package:taskoro/screens/tasks/base_habit_detail_screen.dart';
import 'package:taskoro/screens/tasks/base_habit_screen.dart';
import 'package:taskoro/screens/edit_profile_screen.dart';
import 'package:taskoro/screens/friends/friend_requests_screen.dart';
import 'package:taskoro/screens/main/main_screen.dart';
import 'package:taskoro/screens/main/login_screen.dart';
import 'package:taskoro/screens/tasks/base_task_detail_screen.dart';
import 'package:taskoro/screens/tournament_detail.dart';
import 'package:taskoro/screens/tournaments_screen.dart';
import 'package:taskoro/theme/app_theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 bg message: ${message.messageId}');
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final userProvider = UserProvider();
  await userProvider.loadFromStorage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp( MyApp(userProvider: userProvider));

}



class MyApp extends StatefulWidget {
  final UserProvider userProvider;
  const MyApp({required this.userProvider, super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    final fb = FirebaseMessaging.instance;
    fb.getToken().then((token) {
      print('🔑 FCM token: $token');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      print('📨 onMessage: ${msg.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      print('🚀 onMessageOpenedApp: ${msg.data}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: widget.userProvider),

        ChangeNotifierProvider<ActivityLogProvider>(
          create: (context) => ActivityLogProvider(
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(create: (_) => DuelProvider()),
        ChangeNotifierProvider(
          create: (ctx) => BaseTaskProvider(ctx.read<UserProvider>()),
        ),
        // 3. Привычки (фильтр на основе BaseTaskProvider)
        ChangeNotifierProvider(
          create: (ctx) => BaseHabitProvider(ctx.read<BaseTaskProvider>()),
        ),
        // 4. Ежедневки (фильтр на основе BaseTaskProvider)
        ChangeNotifierProvider(
          create: (ctx) => BaseDailyProvider(ctx.read<BaseTaskProvider>()),
        ),
        ChangeNotifierProxyProvider<UserProvider, BaseTaskProvider>(
          create: (ctx) => BaseTaskProvider(ctx.read<UserProvider>()),
          update: (ctx, userProv, prev) =>
              BaseTaskProvider(userProv),
        ),
        ChangeNotifierProxyProvider<UserProvider, TournamentsProvider>(
          create: (_) => TournamentsProvider(userProvider: UserProvider()),
          update: (_, userProvider, prev) => TournamentsProvider(userProvider: userProvider),
        ),
        ChangeNotifierProxyProvider<UserProvider, TasksProvider>(
          create: (context) => TasksProvider(userProvider: context.read<UserProvider>()),
          update: (context, userProvider, previous) => TasksProvider(userProvider: userProvider),
        ),
        ChangeNotifierProxyProvider<UserProvider, NotesProvider>(
          create: (context) => NotesProvider(context.read<UserProvider>()),
          update: (_, userProvider, __) => NotesProvider(userProvider),
        ),
        ChangeNotifierProxyProvider<UserProvider, AchievementProvider>(
          create: (context) => AchievementProvider(userProvider: Provider.of<UserProvider>(context, listen: false)),
          update: (_, userProvider, achievementProvider) => AchievementProvider(userProvider: userProvider),
        ),
        ChangeNotifierProxyProvider<UserProvider, ShopProvider>(
          create: (_) => ShopProvider(userProvider: UserProvider()),
          update: (_, userProvider, prev) => ShopProvider(userProvider: userProvider),
        ),
        // Добавляем FriendsProvider, который зависит от UserProvider
        ChangeNotifierProvider(
          create: (context) => FriendsProvider(
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Daskoro — Игровая прокачка дисциплины и привычек',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        routes: {
          '/edit-profile': (context) => const ProfileEditScreen(),
          "/base-habits": (context) => const BaseHabitScreen(),
          "/base-daily": (context) => const BaseDailyScreen(),
          "/friend-requests": (context) => const FriendRequestsScreen(),
          "/base-task-detail": (context) => const BaseTaskDetailScreen(),
          "base-habit-detail": (context) => const BaseHabitDetailScreen(),
          "/base-daily-detail": (context) => const BaseDailyDetailScreen(),
          TournamentsScreen.routeName: (_) => TournamentsScreen(),
          LeaderboardScreen.routeName: (_) => LeaderboardScreen(),
          DuelsScreen.routeName: (_) => DuelsScreen(),
          CreateDuelScreen.routeName: (_) => CreateDuelScreen(),
          TournamentDetailScreen.routeName: (_) => TournamentDetailScreen(),
          TaskStakeScreen.routeName: (_) => const TaskStakeScreen(),
          FriendsScreen.routeName: (_) => const FriendsScreen(),
          DuelDetailScreen.routeName  : (_) => const DuelDetailScreen(),
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



