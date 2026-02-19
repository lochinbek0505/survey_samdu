import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart'; // kIsWeb uchun
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:survey_samdu/admin/provider/AdminProvider.dart';
import 'package:survey_samdu/models/groups_model.dart';
import 'package:survey_samdu/models/session_model.dart';

import '../../models/fakultet_model.dart';
import '../../models/session_list_model.dart';
import '../../service/AppConsts.dart';

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

class CreateSessionDialog extends StatefulWidget {
  const CreateSessionDialog({super.key});

  @override
  State<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<CreateSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  DateTime? _selectedDateTime;
  num? _selectedSurveyId;

  // Fakultet va guruh uchun yangi o'zgaruvchilar
  Faculties? _selectedFaculty;
  Items? _selectedGroup;
  bool _loadingGroups = false;
  List<Items>? _groups;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _loadGroups(num departmentId) async {
    setState(() {
      _loadingGroups = true;
      _selectedGroup = null;
      _groups = null;
    });

    try {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final groupsModel = await provider.getGroups(departmentId);

      setState(() {
        _groups = groupsModel?.itemsList ?? [];
        _loadingGroups = false;
      });
    } catch (e) {
      setState(() {
        _loadingGroups = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guruhlarni yuklashda xatolik: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getGroupName() {
    // Agar guruh tanlangan bo'lsa, guruh nomini qaytaradi
    // Aks holda fakultet nomini qaytaradi
    if (_selectedGroup != null) {
      return _selectedGroup!.name ?? '';
    } else if (_selectedFaculty != null) {
      return _selectedFaculty!.name ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.deepPurple,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Yangi sessiya yaratish',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Sessiya nomi',
                      hintText: '1-kurs baholash',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Nomini kiriting' : null,
                  ),
                  const SizedBox(height: 16),

                  // Fakultet tanlash
                  DropdownButtonFormField<Faculties>(
                    decoration: InputDecoration(
                      labelText: 'Fakultet',
                      prefixIcon: const Icon(Icons.business),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: _selectedFaculty,
                    items: AppConsts.fakultetlar.dataListList?.map((faculty) {
                      return DropdownMenuItem<Faculties>(
                        value: faculty,
                        child: SizedBox(
                          width: 300,
                          child: Text(faculty.name ?? ''),
                        ),
                      );
                    }).toList(),
                    onChanged: (Faculties? value) {
                      setState(() {
                        _selectedFaculty = value;
                        _selectedGroup = null;
                      });
                      if (value?.id != null) {
                        _loadGroups(value!.id!);
                      }
                    },
                    validator: (value) =>
                    value == null ? 'Fakultetni tanlang' : null,
                  ),
                  const SizedBox(height: 16),

                  // Guruh tanlash (ixtiyoriy)
                  if (_loadingGroups)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (_selectedFaculty != null && _groups != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<Items>(
                          decoration: InputDecoration(
                            labelText: 'Guruh (ixtiyoriy)',
                            hintText: 'Guruh tanlanmasa fakultet ishlatiladi',
                            prefixIcon: const Icon(Icons.group),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          value: _selectedGroup,
                          items: _groups?.map((group) {
                            return DropdownMenuItem<Items>(
                              value: group,
                              child: SizedBox(
                                width: 300,
                                child: Text(group.name ?? ''),
                              ),
                            );
                          }).toList(),
                          onChanged: (Items? value) {
                            setState(() {
                              _selectedGroup = value;
                            });
                          },
                          // validator ni o'chiramiz - majburiy emas
                        ),
                        if (_selectedGroup == null && _selectedFaculty != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                  size: 16,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ishlatiladi: ${_selectedFaculty!.name}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Avval fakultetni tanlang',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: 'Davomiyligi (daqiqa)',
                      hintText: '90',
                      prefixIcon: const Icon(Icons.timer),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Davomiyligini kiriting'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDateTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Boshlanish vaqti',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _selectedDateTime != null
                            ? DateFormat(
                          'dd.MM.yyyy HH:mm',
                        ).format(_selectedDateTime!)
                            : 'Vaqtni tanlang',
                        style: TextStyle(
                          color: _selectedDateTime != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Bekor qilish'),
                      ),
                      const SizedBox(width: 8),
                      Consumer<AdminProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton.icon(
                            onPressed: provider.loading
                                ? null
                                : () async {
                              if (_formKey.currentState!.validate() &&
                                  _selectedDateTime != null) {
                                final data = {
                                  "survey": 3,
                                  "name": _nameController.text,
                                  "group_name": _getGroupName(),
                                  "start_time": _selectedDateTime!
                                      .toIso8601String(),
                                  "duration": int.parse(
                                    _durationController.text,
                                  ),
                                };

                                final result = await provider
                                    .createSession(data);
                                await provider.getSessions(context);

                                Navigator.pop(context);
                                _showSuccessDialog(context, result);
                              } else if (_selectedDateTime == null) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Boshlanish vaqtini tanlang',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            icon: provider.loading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.check),
                            label: Text(
                              provider.loading ? 'Yaratilmoqda...' : 'Yaratish',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, SessionModel session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QRCodeDialog(
        session: DataList(
          id: session.id,
          survey: session.survey,
          name: session.name,
          groupName: session.groupName,
          code: session.code,
          startTime: session.startTime,
          duration: session.duration,
          isActive: session.isActive,
        ),
        isNewSession: true,
      ),
    );
  }
}

class EditSessionDialog extends StatefulWidget {
  final DataList session;

  const EditSessionDialog({super.key, required this.session});

  @override
  State<EditSessionDialog> createState() => _EditSessionDialogState();
}

class _EditSessionDialogState extends State<EditSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  DateTime? _selectedDateTime;

  // Fakultet va guruh uchun o'zgaruvchilar
  Faculties? _selectedFaculty;
  Items? _selectedGroup;
  bool _loadingGroups = false;
  List<Items>? _groups;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session.name);
    _durationController = TextEditingController(
      text: widget.session.duration.toString(),
    );
    _selectedDateTime = DateTime.parse(widget.session.startTime!);

    // Eski group_name dan fakultet va guruhni aniqlashga harakat qilish
    _initializeFacultyAndGroup();
  }

  void _initializeFacultyAndGroup() {
    final groupName = widget.session.groupName ?? '';

    // Fakultetlarni tekshirish
    for (var faculty in AppConsts.fakultetlar.dataListList ?? []) {
      if (faculty.name == groupName) {
        _selectedFaculty = faculty;
        // Fakultet topildi, guruhlarni yuklash kerak
        if (faculty.id != null) {
          _loadGroups(faculty.id!);
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDateTime ?? DateTime.now(),
        ),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _loadGroups(num departmentId) async {
    setState(() {
      _loadingGroups = true;
      _selectedGroup = null;
      _groups = null;
    });

    try {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final groupsModel = await provider.getGroups(departmentId);

      setState(() {
        _groups = groupsModel?.itemsList ?? [];
        _loadingGroups = false;

        // Agar mavjud group_name guruhlar ro'yxatida bo'lsa, uni tanlash
        final currentGroupName = widget.session.groupName ?? '';
        for (var group in _groups ?? []) {
          if (group.name == currentGroupName) {
            _selectedGroup = group;
            break;
          }
        }
      });
    } catch (e) {
      setState(() {
        _loadingGroups = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guruhlarni yuklashda xatolik: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getGroupName() {
    // Agar guruh tanlangan bo'lsa, guruh nomini qaytaradi
    // Aks holda fakultet nomini qaytaradi
    if (_selectedGroup != null) {
      return _selectedGroup!.name ?? '';
    } else if (_selectedFaculty != null) {
      return _selectedFaculty!.name ?? '';
    }
    return widget.session.groupName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Sessiyani tahrirlash',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Sessiya nomi',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Nomini kiriting' : null,
                  ),
                  const SizedBox(height: 16),

                  // Fakultet tanlash
                  DropdownButtonFormField<Faculties>(
                    decoration: InputDecoration(
                      labelText: 'Fakultet',
                      prefixIcon: const Icon(Icons.business),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: _selectedFaculty,
                    items: AppConsts.fakultetlar.dataListList?.map((faculty) {
                      return DropdownMenuItem<Faculties>(
                        value: faculty,
                        child: SizedBox(
                          width: 300,
                          child: Text(faculty.name ?? ''),
                        ),
                      );
                    }).toList(),
                    onChanged: (Faculties? value) {
                      setState(() {
                        _selectedFaculty = value;
                        _selectedGroup = null;
                      });
                      if (value?.id != null) {
                        _loadGroups(value!.id!);
                      }
                    },
                    validator: (value) =>
                    value == null ? 'Fakultetni tanlang' : null,
                  ),
                  const SizedBox(height: 16),

                  // Guruh tanlash (ixtiyoriy)
                  if (_loadingGroups)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (_selectedFaculty != null && _groups != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<Items>(
                          decoration: InputDecoration(
                            labelText: 'Guruh (ixtiyoriy)',
                            hintText: 'Guruh tanlanmasa fakultet ishlatiladi',
                            prefixIcon: const Icon(Icons.group),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          value: _selectedGroup,
                          items: _groups?.map((group) {
                            return DropdownMenuItem<Items>(
                              value: group,
                              child: SizedBox(
                                width: 300,
                                child: Text(group.name ?? ''),
                              ),
                            );
                          }).toList(),
                          onChanged: (Items? value) {
                            setState(() {
                              _selectedGroup = value;
                            });
                          },
                        ),
                        if (_selectedGroup == null && _selectedFaculty != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                  size: 16,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ishlatiladi: ${_selectedFaculty!.name}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Avval fakultetni tanlang',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: 'Davomiyligi (daqiqa)',
                      prefixIcon: const Icon(Icons.timer),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Davomiyligini kiriting'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDateTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Boshlanish vaqti',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _selectedDateTime != null
                            ? DateFormat(
                          'dd.MM.yyyy HH:mm',
                        ).format(_selectedDateTime!)
                            : 'Vaqtni tanlang',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Bekor qilish'),
                      ),
                      const SizedBox(width: 8),
                      Consumer<AdminProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton.icon(
                            onPressed: provider.loading
                                ? null
                                : () async {
                              if (_formKey.currentState!.validate() &&
                                  _selectedDateTime != null) {
                                final data = {
                                  "survey": widget.session.survey,
                                  "name": _nameController.text,
                                  "group_name": _getGroupName(),
                                  "start_time": _selectedDateTime!
                                      .toIso8601String(),
                                  "duration": int.parse(
                                    _durationController.text,
                                  ),
                                };

                                await provider.updateSession(
                                  data,
                                  widget.session.id,
                                );
                                await provider.getSessions(context);

                                Navigator.pop(context);
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Sessiya muvaffaqiyatli yangilandi',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: provider.loading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.save),
                            label: Text(
                              provider.loading ? 'Saqlanmoqda...' : 'Saqlash',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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

class QRCodeDialog extends StatefulWidget {
  final DataList session;
  final bool isNewSession;

  const QRCodeDialog({
    super.key,
    required this.session,
    this.isNewSession = false,
  });

  @override
  State<QRCodeDialog> createState() => _QRCodeDialogState();
}

class _QRCodeDialogState extends State<QRCodeDialog> {
  final GlobalKey _qrKey = GlobalKey();

  String get surveyUrl =>
      'https://survey.samdu.uz/survey/${widget.session.code}';

  Future<void> _saveQRCode() async {
    try {
      RenderRepaintBoundary boundary =
      _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        // VEB UCHUN: Rasmni brauzer orqali yuklab olish
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "qrcode.png")
          ..click();
        html.Url.revokeObjectUrl(url);

        _showSnackBar('QR kod yuklab olindi', Colors.green);
      } else {
        // MOBIL UCHUN: Oldingi kodingiz
        final result = await ImageGallerySaver.saveImage(pngBytes);
        if (result['isSuccess']) {
          _showSnackBar('QR kod galereyaga saqlandi', Colors.green);
        }
      }
    } catch (e) {
      _showSnackBar('Xatolik: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: surveyUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Havola nusxalandi'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isNewSession) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[700],
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Sessiya muvaffaqiyatli yaratildi!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple[100]!, Colors.deepPurple[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.session.name ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Guruh: ${widget.session.groupName}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: surveyUrl,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.deepPurple,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.vpn_key,
                            color: Colors.deepPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Sessiya kodi:',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.session.code ?? '',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.link, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          surveyUrl,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: _copyLink,
                        icon: Icon(Icons.copy, color: Colors.blue[700]),
                        tooltip: 'Nusxalash',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saveQRCode,
                        icon: const Icon(Icons.download),
                        label: const Text('Yuklab olish'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Yopish'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}