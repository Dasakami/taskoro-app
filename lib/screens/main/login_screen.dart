import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:taskoro/widgets/animated_background.dart';
import 'package:taskoro/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submitForm() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
      return;
    }

    try {
      if (_isLogin) {
        await context.read<UserProvider>().login(username, password);
      } else {
        await context.read<UserProvider>().register(username, password);
      }

      // TODO: Переход на главный экран
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _loginDemo() {
    context.read<UserProvider>().initDemoUser();
  }

  @override
  Widget build(BuildContext context) {
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
                    // Logo/Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: AppColors.gradientPrimary,
                      ).createShader(bounds),
                      child: Text(
                        'TASKORO',
                        style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontSize: 40,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Игровая прокачка дисциплины и привычек',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Login/Register Card
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

                            // Username field
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Имя пользователя',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Пароль',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Toggle mode
                            TextButton(
                              onPressed: _toggleMode,
                              child: Text(
                                _isLogin
                                    ? 'Нет аккаунта? Зарегистрироваться'
                                    : 'Уже есть аккаунт? Войти',
                                style: TextStyle(color: AppColors.accentSecondary),
                              ),
                            ),

                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),

                            // Demo button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _loginDemo,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.accentTertiary),
                                ),
                                child: const Text(
                                  'Демо режим',
                                  style: TextStyle(color: AppColors.accentTertiary),
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