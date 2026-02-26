import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_samdu/admin/provider/AdminProvider.dart';

import '../../models/session_list_model.dart';
import '../widgets/CreateSessionDialog.dart';
import '../widgets/EditSessionDialog.dart';
import '../widgets/QRCodeDialog.dart';
import '../widgets/SessionCard.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).getSessions(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Sessiyalar boshqaruvi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = provider.sessions.dataListList ?? [];

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hozircha sessiyalar yo\'q',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yangi sessiya yaratish uchun + tugmasini bosing',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.getSessions(context),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return SessionCard(
                  session: session,
                  onEdit: () => _showEditDialog(context, session),
                  onDelete: () => _showDeleteDialog(context, session.id!),
                  onViewQR: () => _showQRDialog(context, session),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Yangi sessiya'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateSessionDialog(),
    );
  }

  void _showEditDialog(BuildContext context, DataList session) {
    showDialog(
      context: context,
      builder: (context) => EditSessionDialog(session: session),
    );
  }

  void _showDeleteDialog(BuildContext context, num id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Bu sessiyani o\'chirishga ishonchingiz komilmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AdminProvider>(
                context,
                listen: false,
              ).deleteSession(id);
              await Provider.of<AdminProvider>(
                context,
                listen: false,
              ).getSessions(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sessiya muvaffaqiyatli o\'chirildi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  void _showQRDialog(BuildContext context, DataList session) {
    showDialog(
      context: context,
      builder: (context) => QRCodeDialog(session: session),
    );
  }
}
