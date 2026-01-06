import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/state_wrapper.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  
  File? _pickedImageFile;
  String? _currentAvatarUrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user!;
    _usernameController = TextEditingController(text: user.username);
    _bioController = TextEditingController(text: user.bio ?? '');
    _currentAvatarUrl = user.avatarUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (picked != null) {
      setState(() {
        _pickedImageFile = File(picked.path);
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
      await userProvider.updateProfile(
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        avatarFile: _pickedImageFile,
      );

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Профиль успешно обновлён');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Ошибка при обновлении профиля: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Определяем, какой аватар показывать
    Widget avatarWidget;
    
    if (_pickedImageFile != null) {
      // Показываем выбранный файл
      avatarWidget = CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_pickedImageFile!),
      );
    } else if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
      // Показываем текущий аватар с сервера
      avatarWidget = CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_currentAvatarUrl!),
      );
    } else {
      // Показываем placeholder
      avatarWidget = const CircleAvatar(
        radius: 50,
        child: Icon(Icons.person, size: 50),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование профиля'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Аватар
              Stack(
                children: [
                  avatarWidget,
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                        iconSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Изменить аватар'),
              ),
              
              if (_pickedImageFile != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _pickedImageFile = null;
                    });
                  },
                  icon: const Icon(Icons.clear, color: Colors.red),
                  label: const Text('Удалить выбранное фото', 
                    style: TextStyle(color: Colors.red)),
                ),
              
              const SizedBox(height: 16),
              
              // Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Имя пользователя',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
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
              
              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'О себе',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                  hintText: 'Расскажите о себе...',
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Сохранить', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}