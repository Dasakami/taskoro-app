import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/state_wrapper.dart';
import '../theme/app_theme.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  XFile? _pickedImage;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user!;
    _usernameController = TextEditingController(text: user.username);
    _bioController = TextEditingController(text: user.bio ?? '');
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
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
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
        avatarFilePath: _pickedImage?.path,
      );

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Профиль успешно обновлён');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Ошибка при обновлении профиля';
        if (e.toString().contains('username')) {
          errorMessage = 'Это имя пользователя уже занято';
        }
        AppSnackBar.showError(context, errorMessage);
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
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Редактирование профиля'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar section
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.accentPrimary.withOpacity(0.2),
                    backgroundImage: _pickedImage != null
                        ? FileImage(File(_pickedImage!.path))
                        : (user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null) as ImageProvider?,
                    child: _pickedImage == null && user.avatarUrl == null
                        ? const Icon(Icons.person, size: 60, color: AppColors.textSecondary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundSecondary,
                          width: 3,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: _pickImage,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              if (_pickedImage != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _pickedImage = null;
                    });
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Отменить изменение'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Имя пользователя',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Введите имя пользователя';
                  }
                  if (v.trim().length < 3) {
                    return 'Минимум 3 символа';
                  }
                  if (v.trim().length > 30) {
                    return 'Максимум 30 символов';
                  }
                  // Проверка на допустимые символы
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                    return 'Только буквы, цифры и _';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Bio field
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: 'О себе',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  alignLabelWithHint: true,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Сохранить изменения',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Отмена'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}