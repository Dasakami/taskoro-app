import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _avatarUrl;
  XFile? _pickedImage;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user!;
    _usernameController = TextEditingController(text: user.username);
    _bioController = TextEditingController(text: user.bio ?? '');
    _avatarUrl = user.avatarUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
        _avatarUrl = null; // Сбросим URL, если выбрали локальную картинку
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final userProvider = context.read<UserProvider>();

    try {
      // Заменить на метод обновления профиля в твоём UserProvider
      await userProvider.updateProfile(
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        avatarFilePath: _pickedImage?.path,
        avatarUrl: _avatarUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль успешно обновлён')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обновлении профиля: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarWidget = _pickedImage != null
        ? CircleAvatar(
      radius: 50,
      backgroundImage: Image.file(
        File(_pickedImage!.path),
        fit: BoxFit.cover,
      ).image,
    )
        : (_avatarUrl != null
        ? CircleAvatar(
      radius: 50,
      backgroundImage: NetworkImage(_avatarUrl!),
    )
        : const CircleAvatar(
      radius: 50,
      child: Icon(Icons.person, size: 50),
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('Редактирование профиля')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              avatarWidget,
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Изменить аватар'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Имя пользователя',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Введите имя пользователя';
                  }
                  if (v.trim().length < 3) {
                    return 'Минимум 3 символа';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'О себе',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
