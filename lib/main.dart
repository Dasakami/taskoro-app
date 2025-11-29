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
import 'package:taskoro/services/api_service.dart';
import 'package:taskoro/theme/app_theme.dart';

// Import all screens
import 'package:taskoro/screens/main/main_screen.dart';
import 'package:taskoro/screens/main/login_screen.dart';
import 'package:taskoro/screens/edit_profile_screen.dart';
import 'package:taskoro/screens/tasks/base_daily_detail_screen.dart';
import 'package:taskoro/screens/tasks/base_daily_screen.dart';
import 'package:taskoro/screens/tasks/base_habit_detail_screen.dart';
import 'package:taskoro/screens/tasks/base_habit_screen.dart';
import 'package:taskoro/screens/tasks/base_task_detail_screen.dart';
import 'package:taskoro/screens/friends/friend_requests_screen.dart';
import 'package:taskoro/screens/friends/friends_screen.dart';
import 'package:taskoro/screens/duels/create_duel_screen.dart';
import 'package:taskoro/screens/duels/duel_detail_screen.dart';
import 'package:taskoro/screens/duels/duels_screen.dart';
import 'package:taskoro/screens/duels/task_stake_screen.dart';
import 'package:taskoro/screens/leaderboard_screen.dart';
import 'package:taskoro/screens/tournament_detail.dart';
import 'package:taskoro/screens/tournaments_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 bg message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize API Service
  await ApiService().init();
  
  // Initialize UserProvider
  final userProvider = UserProvider();
  await userProvider.init();
  
  runApp(MyApp(userProvider: userProvider));
}

class MyApp extends StatefulWidget {
  final UserProvider userProvider;
  
  const MyApp({required this.userProvider, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    final fb = FirebaseMessaging.instance;
    
    fb.getToken().then((token) {
      debugPrint('🔑 FCM token: $token');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      debugPrint('📨 onMessage: ${msg.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      debugPrint('🚀 onMessageOpenedApp: ${msg.data}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. UserProvider - основной провайдер
        ChangeNotifierProvider<UserProvider>.value(
          value: widget.userProvider,
        ),

        // 2. Провайдеры, зависящие от UserProvider
        ChangeNotifierProxyProvider<UserProvider, ActivityLogProvider>(
          create: (context) => ActivityLogProvider(
            userProvider: context.read<UserProvider>(),
          ),
          update: (context, userProvider, previous) =>
              previous ?? ActivityLogProvider(userProvider: userProvider),
        ),

        ChangeNotifierProxyProvider<UserProvider, BaseTaskProvider>(
          create: (context) => BaseTaskProvider(context.read<UserProvider>()),
          update: (context, userProvider, previous) =>
              previous ?? BaseTaskProvider(userProvider),
        ),

        ChangeNotifierProxyProvider<UserProvider, TasksProvider>(
          create: (context) => TasksProvider(
            userProvider: context.read<UserProvider>(),
          ),
          update: (context, userProvider, previous) =>
              previous ?? TasksProvider(userProvider: userProvider),
        ),

        ChangeNotifierProxyProvider<UserProvider, NotesProvider>(
          create: (context) => NotesProvider(context.read<UserProvider>()),
          update: (context, userProvider, previous) =>
              previous ?? NotesProvider(userProvider),
        ),

        ChangeNotifierProxyProvider<UserProvider, AchievementProvider>(
          create: (context) => AchievementProvider(
            userProvider: context.read<UserProvider>(),
          ),
          update: (context, userProvider, previous) =>
              previous ?? AchievementProvider(userProvider: userProvider),
        ),

        ChangeNotifierProxyProvider<UserProvider, ShopProvider>(
          create: (context) => ShopProvider(
            userProvider: context.read<UserProvider>(),
          ),
          update: (context, userProvider, previous) =>
              previous ?? ShopProvider(userProvider: userProvider),
        ),

        ChangeNotifierProxyProvider<UserProvider, FriendsProvider>(
          create: (context) => FriendsProvider(
            userProvider: context.read<UserProvider>(),
          ),
          update: (context, userProvider, previous) =>
              previous ?? FriendsProvider(userProvider: userProvider),
        ),

        ChangeNotifierProxyProvider<UserProvider, TournamentsProvider>(
          create: (context) => TournamentsProvider(
            userProvider: context.read<UserProvider>(),
          ),
          update: (context, userProvider, previous) =>
              previous ?? TournamentsProvider(userProvider: userProvider),
        ),

        // 3. Провайдеры, зависящие от BaseTaskProvider
        ChangeNotifierProxyProvider<BaseTaskProvider, BaseHabitProvider>(
          create: (context) => BaseHabitProvider(
            context.read<BaseTaskProvider>(),
          ),
          update: (context, baseTaskProvider, previous) =>
              previous ?? BaseHabitProvider(baseTaskProvider),
        ),

        ChangeNotifierProxyProvider<BaseTaskProvider, BaseDailyProvider>(
          create: (context) => BaseDailyProvider(
            context.read<BaseTaskProvider>(),
          ),
          update: (context, baseTaskProvider, previous) =>
              previous ?? BaseDailyProvider(baseTaskProvider),
        ),

        // 4. Независимые провайдеры
        ChangeNotifierProvider(
          create: (_) => DuelProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Daskoro — Игровая прокачка дисциплины и привычек',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        
        // Глобальный обработчик ошибок навигации
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Ошибка')),
              body: const Center(
                child: Text('Страница не найдена'),
              ),
            ),
          );
        },
        
        routes: {
          '/edit-profile': (context) => const ProfileEditScreen(),
          '/base-habits': (context) => const BaseHabitScreen(),
          '/base-daily': (context) => const BaseDailyScreen(),
          '/friend-requests': (context) => const FriendRequestsScreen(),
          '/base-task-detail': (context) => const BaseTaskDetailScreen(),
          '/base-habit-detail': (context) => const BaseHabitDetailScreen(),
          '/base-daily-detail': (context) => const BaseDailyDetailScreen(),
          TournamentsScreen.routeName: (_) => const TournamentsScreen(),
          LeaderboardScreen.routeName: (_) => LeaderboardScreen(),
          DuelsScreen.routeName: (_) => const DuelsScreen(),
          CreateDuelScreen.routeName: (_) => const CreateDuelScreen(),
          TournamentDetailScreen.routeName: (_) => const TournamentDetailScreen(),
          TaskStakeScreen.routeName: (_) => const TaskStakeScreen(),
          FriendsScreen.routeName: (_) => const FriendsScreen(),
          DuelDetailScreen.routeName: (_) => const DuelDetailScreen(),
        },
        
        home: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            // Показываем загрузку во время инициализации
            if (userProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Показываем ошибку если есть
            if (userProvider.error != null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ошибка: ${userProvider.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          userProvider.clearError();
                          userProvider.init();
                        },
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return userProvider.isAuthenticated
                ? const MainScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}