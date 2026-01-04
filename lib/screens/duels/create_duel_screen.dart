// screens/create_duel_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/duel_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';


class CreateDuelScreen extends StatefulWidget {
  static const routeName = '/duel-create';

  const CreateDuelScreen({super.key});
  @override
  _CreateDuelScreenState createState() => _CreateDuelScreenState();
}

class _CreateDuelScreenState extends State<CreateDuelScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _opponentId;
  String _tasks = '';
  int? _coinsStake;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final token =
        Provider.of<UserProvider>(context, listen: false).accessToken;
    final provider = Provider.of<DuelProvider>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      final taskIds = _tasks
          .split(',')
          .map((e) => int.parse(e.trim()))
          .toList();
      await provider.createDuel(
        opponentId: _opponentId!,
        taskIds: taskIds,
        coinsStake: _coinsStake!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дуэль создана!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая дуэль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID оппонента'),
                keyboardType: TextInputType.number,
                style: AppTheme.darkTheme.textTheme.bodyLarge,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Введите ID' : null,
                onSaved: (v) => _opponentId = int.tryParse(v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                const InputDecoration(labelText: 'ID задач (через ,)'),
                style: AppTheme.darkTheme.textTheme.bodyLarge,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Введите хотя бы одну задачу' : null,
                onSaved: (v) => _tasks = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                const InputDecoration(labelText: 'Ставка монет'),
                keyboardType: TextInputType.number,
                style: AppTheme.darkTheme.textTheme.bodyLarge,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Укажите ставку' : null,
                onSaved: (v) => _coinsStake = int.tryParse(v!),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submit,
                child: const Text('Создать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
