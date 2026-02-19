import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // URL strategy uchun
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_samdu/admin/page/StaticsPage.dart';
import 'package:survey_samdu/user/pages/SurveyPage.dart';
import 'package:survey_samdu/user/providers/SessionProvider.dart';

import 'admin/page/AdminPage.dart';
import 'admin/provider/AdminProvider.dart';
import 'admin/provider/SurveysProvider.dart';

void main() {
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SurveyProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => SurveysProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SurveyCodePage()),
      GoRoute(path: '/admin', builder: (context, state) => AdminPage()),
      GoRoute(
        path: '/survey/:sessionCode',
        builder: (context, state) {
          final code = state.pathParameters['sessionCode']!;
          return SurveyPage(session_code: code);
        },
      ),
    ],
    errorBuilder: (context, state) =>
        const ErrorScreen(message: "Sahifa topilmadi"),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Survey SamDU',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class SurveyCodePage extends StatelessWidget {
  const SurveyCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller kiritilgan kodni olish uchun
    final TextEditingController _codeController = TextEditingController();

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.grey.shade100,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SizedBox(
              width: 500,
              height: 400,
              child: Card(
                elevation: 10,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // Card tarkibiga qarab kichrayadi
                    children: [
                      // Yuqoridagi belgi
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 50,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Xush kelibsiz!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Davom etish uchun so'rovnoma kodini kiriting",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30),

                      // Input maydoni (Edit Text)
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Kodni kiriting",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Tasdiqlash tugmasi
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            String code = _codeController.text;

                            // Ma'lumot bilan birga almashtirish
                            context.pushReplacement(
                              '/survey/$code',
                              extra: code, // Shunchaki kodning o'zini yubordik
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Tasdiqlash",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;

  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text("Bosh sahifaga qaytish"),
            ),
          ],
        ),
      ),
    );
  }
}
