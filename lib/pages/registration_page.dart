import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import 'user_info_page.dart';

/// Страница регистрации: форма с проверкой полей.
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Ключ формы: через него запускаем проверку всех полей
  final _formKey = GlobalKey<FormState>();

  // Controller для каждого TextFormField
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _storyController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // FocusNode для каждого TextFormField
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _storyFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  // Скрыт ли пароль (obscureText)
  bool _hidePass = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _storyController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _storyFocus.dispose();
    _passFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  // Переход фокуса на следующее поле
  void _nextFocus(FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  // ---------- Проверки ----------

  // Имя не может быть пустым
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  // Телефон: не пустой и только цифры
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  // Email: не пустой и в стандартном формате
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Invalid email address';
    }
    return null;
  }

  // Пароль: не пустой и не короче 6 символов
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Подтверждение пароля: должно совпадать с паролем
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != _passController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ---------- Отправка формы ----------

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form is not valid. Please check the fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ---------- Lab 7: сохраняем пользователя в Firebase Realtime Database ----------
    try {
      // push() создаёт новую запись с уникальным ключом внутри users/
      final userRef = FirebaseDatabase.instance.ref('users').push();
      await userRef.set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text,
        'email': _emailController.text.trim(),
        'story': _storyController.text,
        'fcmToken': NotificationService.token,
        'createdAt': ServerValue.timestamp, // время сервера Firebase
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения в Firebase: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Push-уведомление об успешной регистрации
    await NotificationService.show(
      'Регистрация успешна',
      'Добро пожаловать, ${_nameController.text.trim()}!',
    );

    // Сохраняем данные локально через SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text.trim());
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('story', _storyController.text);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserInfoPage()),
    );
  }

  // Рамка со скруглением для полей Full Name и Phone Number
  OutlineInputBorder _roundBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color, width: 2),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Register Form'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Full Name
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              autofocus: true,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _nextFocus(_nameFocus, _phoneFocus),
              validator: _validateName,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                hintText: 'What do people call you?',
                prefixIcon: const Icon(Icons.person),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _nameController.clear,
                ),
                enabledBorder: _roundBorder(Colors.black),
                focusedBorder: _roundBorder(Colors.blue),
                errorBorder: _roundBorder(Colors.red),
                focusedErrorBorder: _roundBorder(Colors.red),
              ),
            ),
            const SizedBox(height: 12),

            // Phone Number: можно ввести только цифры
            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onFieldSubmitted: (_) => _nextFocus(_phoneFocus, _emailFocus),
              validator: _validatePhone,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Where can we reach you?',
                helperText: 'Phone format: (XXX)XXX-XXXX',
                prefixIcon: const Icon(Icons.call),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _phoneController.clear,
                ),
                enabledBorder: _roundBorder(Colors.black),
                focusedBorder: _roundBorder(Colors.blue),
                errorBorder: _roundBorder(Colors.red),
                focusedErrorBorder: _roundBorder(Colors.red),
              ),
            ),
            const SizedBox(height: 12),

            // Email Address
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _nextFocus(_emailFocus, _storyFocus),
              validator: _validateEmail,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                icon: Icon(Icons.mail),
              ),
            ),
            const SizedBox(height: 16),

            // Life Story: многострочное поле
            TextFormField(
              controller: _storyController,
              focusNode: _storyFocus,
              maxLines: 3,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              decoration: const InputDecoration(
                labelText: 'Life Story',
                hintText: 'Tell us about yourself',
                helperText: 'Keep it short, this is just a demo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Password: obscureText + suffixIcon для показа/скрытия
            TextFormField(
              controller: _passController,
              focusNode: _passFocus,
              obscureText: _hidePass,
              maxLength: 8,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  _nextFocus(_passFocus, _confirmPassFocus),
              validator: _validatePassword,
              decoration: InputDecoration(
                labelText: 'Password *',
                hintText: 'Enter the password',
                icon: const Icon(Icons.security),
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePass ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _hidePass = !_hidePass),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Confirm Password: должен совпадать с Password
            TextFormField(
              controller: _confirmPassController,
              focusNode: _confirmPassFocus,
              obscureText: _hidePass,
              maxLength: 8,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitForm(),
              validator: _validateConfirmPassword,
              decoration: const InputDecoration(
                labelText: 'Confirm Password *',
                hintText: 'Confirm the password',
                icon: Icon(Icons.border_color),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Submit Form',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
