import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/AdminProvider.dart';
import 'AdminPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var provider = context.read<AdminProvider>();
      provider.checkLoginStatus();
      if (provider.checkLogin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (builder) => AdminPage()),
        );
      }
    });
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      var provider = Provider.of<AdminProvider>(context, listen: false);
      provider.login(
        _usernameController.text,
        _passwordController.text,
        context,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (builder) => AdminPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AdminProvider>(context);

    // Ekran kengligini aniqlaymiz
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            // Veb uchun formani o'rtacha kenglikda, mobil uchun to'liq kenglikda qilamiz
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 450,
            ),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    "Xush kelibsiz!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  // Username maydoni
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Foydalanuvchi nomi',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Foydalanuvchi nomi kiriting';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password maydoni
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Parol',
                      prefixIcon: const Icon(Icons.lock_open_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6)
                        return 'Parol kamida 6 ta belgidan iborat bo\'lsin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Kirish tugmasi
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      "Tizimga kirish",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
