import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_samdu/admin/page/SessionsPage.dart';
import 'package:survey_samdu/admin/provider/AdminProvider.dart';

import 'LoginPage.dart';
import 'StaticsPage.dart';
import 'SurveyListPage.dart';
import 'SurveysPage.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {



  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: true);
    adminProvider.checkLoginStatus();
    return adminProvider.checkLogin ? const ChosePage() : const LoginPage();
  }
}

class ChosePage extends StatelessWidget {
  const ChosePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ekran o'lchamini aniqlash
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Zamonaviy och kulrang fon
      appBar: AppBar(

        title: const Text(

          "Admin Boshqaruvi",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            // Webda juda yoyilib ketmasligi uchun
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon yoki Logo qismi
                const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Xush kelibsiz!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tizimni boshqarish uchun quyidagi bo'limlardan birini tanlang",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Tugmalar joylashuvi (Mobileda ustun, Webda qator bo'lib tushadi)
                Flex(
                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMenuButton(
                      context,
                      label: "Sessiya yaratish",
                      icon: Icons.add_to_photos_rounded,
                      color: Colors.blueAccent,
                      onTap: () {
                        // Navigation kodini shu yerga qo'ying
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => SessionsPage(),
                          ),
                        );
                      },
                    ),
                    if (!isMobile)
                      const SizedBox(width: 20)
                    else
                      const SizedBox(height: 20),
                    _buildMenuButton(
                      context,
                      label: "Statistikani ko'rish",
                      icon: Icons.bar_chart_rounded,
                      color: Colors.green, // Yashilroq rang
                      onTap: () {
                        // Navigation kodini shu yerga qo'ying
                        Navigator.push(context, MaterialPageRoute(builder: (builder) => SurveyListPage(),));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width*0.7,
                  child: _buildMenuButton(
                    context,
                    label: "So'rovnoma yaratish",
                    icon: Icons.question_mark,
                    color: Colors.red, // Yashilroq rang
                    onTap: () {
                      // Navigation kodini shu yerga qo'ying
                      Navigator.push(context, MaterialPageRoute(builder: (builder) => SurveysPage(),));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Zamonaviy tugma vidjeti
  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Expanded(
      flex: isMobile ? 0 : 1,
      child: SizedBox(
        width: isMobile ? double.infinity : null,
        height: 120, // Tugma balandligi
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: color,
            elevation: 4,
            shadowColor: color.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(color: color.withOpacity(0.1), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
