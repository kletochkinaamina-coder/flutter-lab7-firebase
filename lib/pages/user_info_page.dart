import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Страница с данными пользователя, прочитанными из SharedPreferences.
class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  String _name = '';
  String _phone = '';
  String _email = '';
  String _story = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Читаем сохранённые данные
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('name') ?? '';
      _phone = prefs.getString('phone') ?? '';
      _email = prefs.getString('email') ?? '';
      _story = prefs.getString('story') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('User Info'),
      ),
      body: Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(_name, style: const TextStyle(fontSize: 18)),
              subtitle: _story.isEmpty ? null : Text(_story),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(_phone),
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: Text(_email),
            ),
          ],
        ),
      ),
    );
  }
}
