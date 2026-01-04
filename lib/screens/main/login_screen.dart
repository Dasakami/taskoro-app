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
  final _emailController = TextEditingController();
  final _rePasswordController = TextEditingController();

  bool _isLogin = true;
  int? _selectedClassId;

  @override
  void initState() {
    super.initState();
    final prov = context.read<UserProvider>();
    prov.fetchCharacterClasses().catchError((e) {
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
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim();
    final rePassword = _rePasswordController.text.trim();
    final classId = _selectedClassId;

    if (username.isEmpty || password.isEmpty ||
        (!_isLogin && (email.isEmpty || rePassword.isEmpty || classId == null))) {
      return _showSnack('Пожалуйста, заполните все поля');
    }
    if (!_isLogin && password != rePassword) {
      return _showSnack('Пароли не совпадают');
    }

    try {
      final prov = context.read<UserProvider>();
      if (_isLogin) {
        await prov.login(username, password);
      } else {
        if (classId == null) {
          return _showSnack('Выберите класс персонажа');
        }
        await prov.register(username, email, password, classId);
      }

      // Проверяем, что после логина/регистрации user не null
      if (!prov.isAuthenticated || prov.user == null) {
        return _showSnack('Не удалось войти, попробуйте ещё раз');
      }

      // Навигация только если user существует
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showSnack(e.toString());
    }
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
                    // Logo/Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: AppColors.gradientPrimary,
                      ).createShader(bounds),
                      child: Text(
                        'DASKORO',
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

                    // Card с формой
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

                            if (!_isLogin) ...[
                              if (loading)
                                const Center(child: CircularProgressIndicator())
                              else ...[
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'E-mail',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                TextField(
                                  controller: _rePasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Подтвердите пароль',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                ),
                                const SizedBox(height: 16),

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
                                    prefixIcon: Icon(Icons.shield_outlined),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],

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

                            TextButton(
                              onPressed: _toggleMode,
                              child: Text(
                                _isLogin
                                    ? 'Нет аккаунта? Зарегистрироваться'
                                    : 'Уже есть аккаунт? Войти',
                                style:
                                TextStyle(color: AppColors.accentSecondary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),

                            SizedBox(height: AppSizes.md),
                            Text(
                              'Введите данные для входа',
                              style: Theme.of(context).textTheme.bodyMedium,
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
