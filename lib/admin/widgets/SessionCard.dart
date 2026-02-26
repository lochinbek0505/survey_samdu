import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/session_list_model.dart';

class SessionCard extends StatelessWidget {
  final DataList session;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewQR;

  const SessionCard({
    super.key,
    required this.session,
    required this.onEdit,
    required this.onDelete,
    required this.onViewQR,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = DateTime.parse(session.startTime!);
    final isActive = session.isActive ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Guruh: ${session.groupName}     ${session.responseCount} marta javob berilgan',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Faol' : 'Nofaol',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(startTime),
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${session.duration} daqiqa',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.vpn_key, size: 20, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    'Kod: ${session.code}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewQR,
                    icon: const Icon(Icons.qr_code),
                    label: const Text('QR kod'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  color: Colors.blue,
                  tooltip: 'Tahrirlash',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  tooltip: 'O\'chirish',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
