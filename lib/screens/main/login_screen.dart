import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:taskoro/widgets/animated_background.dart';
import 'package:taskoro/theme/app_theme.dart';
import 'package:taskoro/models/character_class_model.dart'; // поправь путь

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController   = TextEditingController();
  final _passwordController   = TextEditingController();
  final _emailController      = TextEditingController();
  final _rePasswordController = TextEditingController();

  bool _isLogin = true;
  int? _selectedClassId;

  @override
  void initState() {
    super.initState();
    // загружаем классы при старте экрана
    final prov = context.read<UserProvider>();
    prov.fetchCharacterClasses().catchError((e) {
      // можно показать ошибку, но не критично
      debugPrint('Ошибка загрузки классов: $e');
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _submitForm() async {
    final username   = _usernameController.text.trim();
    final password   = _passwordController.text.trim();
    final email      = _emailController.text.trim();
    final rePassword = _rePasswordController.text.trim();
    final classId    = _selectedClassId;

    if (username.isEmpty || password.isEmpty ||
        (!_isLogin && (email.isEmpty || rePassword.isEmpty || classId == null))) {
      return _showSnack('Пожалуйста, заполните все поля');
    }
    if (!_isLogin && password != rePassword) {
      return _showSnack('Пароли не совпадают');
    }

    try {
      if (_isLogin) {
        await context.read<UserProvider>().login(username, password);
      } else {
        await context.read<UserProvider>()
            .register(username, email, password, classId!);
      }
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  void _loginDemo() {
    context.read<UserProvider>().initDemoUser();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UserProvider>();
    final classes = prov.characterClasses;
    final loading = prov.isLoadingClasses;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Title...
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: AppColors.gradientPrimary,
                      ).createShader(bounds),
                      child: Text(
                        'TASKORO',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge!
                            .copyWith(fontSize: 40, letterSpacing: 3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Игровая прокачка дисциплины и привычек',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Card c формой
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              _isLogin ? 'Вход' : 'Регистрация',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 24),

                            // Username
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Имя пользователя',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Пароль',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Режим регистрации: email, подтверждение, класс
                            if (!_isLogin) ...[
                              if (loading)
                                const Center(child: CircularProgressIndicator())
                              else ...[
                                // E-mail
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'E-mail',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Подтверждение пароля
                                TextField(
                                  controller: _rePasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Подтвердите пароль',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Дропдаун с классами из бэка
                                DropdownButtonFormField<int>(
                                  value: _selectedClassId,
                                  items: classes.map((cls) {
                                    return DropdownMenuItem<int>(
                                      value: cls.id,
                                      child: Text(cls.name),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedClassId = val;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Класс персонажа',
                                    prefixIcon:
                                    Icon(Icons.shield_outlined),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],

                            // Кнопка отправки
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                child: Text(
                                  _isLogin ? 'Войти' : 'Зарегистрироваться',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Переключение режима
                            TextButton(
                              onPressed: _toggleMode,
                              child: Text(
                                _isLogin
                                    ? 'Нет аккаунта? Зарегистрироваться'
                                    : 'Уже есть аккаунт? Войти',
                                style: TextStyle(
                                    color: AppColors.accentSecondary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),

                            // Демо режим
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _loginDemo,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.accentTertiary),
                                ),
                                child: const Text(
                                  'Демо режим',
                                  style: TextStyle(
                                      color: AppColors.accentTertiary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
