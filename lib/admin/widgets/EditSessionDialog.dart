import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/fakultet_model.dart';
import '../../models/groups_model.dart';
import '../../models/session_list_model.dart';
import '../../models/surveys_model.dart';
import '../../service/AppConsts.dart';
import '../provider/AdminProvider.dart';

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
  SurveyData? _selectedSurvey;

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

    // So'rovnomalarni yuklash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.getSurveys().then((_) {
        // Joriy surveyni topish
        final surveys = provider.surveysModel.dataListList;
        if (surveys != null) {
          for (var survey in surveys) {
            if (survey.id == widget.session.survey) {
              setState(() {
                _selectedSurvey = survey;
              });
              break;
            }
          }
        }
      });
    });

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
    // Agar ikkalasi ham tanlanmagan bo'lsa, sessiya nomini qaytaradi
    if (_selectedGroup != null) {
      return _selectedGroup!.name ?? '';
    } else if (_selectedFaculty != null) {
      return _selectedFaculty!.name ?? '';
    }
    return _nameController.text.trim();
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

                  // So'rovnoma tanlash
                  Consumer<AdminProvider>(
                    builder: (context, provider, child) {
                      if (provider.loading) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return DropdownButtonFormField<SurveyData>(
                        decoration: InputDecoration(
                          labelText: 'So\'rovnoma',
                          prefixIcon: const Icon(Icons.poll),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _selectedSurvey,
                        items: provider.surveysModel.dataListList?.map((
                          survey,
                        ) {
                          return DropdownMenuItem<SurveyData>(
                            value: survey,
                            child: SizedBox(
                              width: 300,
                              child: Text(survey.title ?? ''),
                            ),
                          );
                        }).toList(),
                        onChanged: (SurveyData? value) {
                          setState(() {
                            _selectedSurvey = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'So\'rovnomani tanlang' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fakultet tanlash
                  DropdownButtonFormField<Faculties>(
                    decoration: InputDecoration(
                      labelText: 'Fakultet (ixtiyoriy)',
                      hintText: 'Tanlanmasa sessiya nomi ishlatiladi',
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
                  ),
                  if (_selectedFaculty == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Fakultet tanlanmasa sessiya nomi group_name sifatida ishlatiladi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                                Icon(
                                  Icons.info_outline,
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
                                        "survey": _selectedSurvey!.id,
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
