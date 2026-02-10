import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../providers/SessionProvider.dart';
import '../widgets/DepartmentDropdown.dart';
import '../widgets/FacultyDropdown.dart';
import '../widgets/TeacherDropdown.dart';

class SurveyPage extends StatefulWidget {
  String session_code;

  SurveyPage({super.key, required this.session_code});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  Map<int, dynamic> answers = {};

  Map<int, Map<String, dynamic>> selectedFaculty = {}; // {id, name}
  Map<int, Map<String, dynamic>> selectedDepartment = {}; // {id, name}
  Map<int, Map<String, dynamic>> selectedTeacher = {}; // {id, name}

  String? _deviceId;
  bool _isSurveyCompleted = false;

  // Add ScrollController to preserve scroll position
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getDeviceId();
    _checkSurveyCompletion();
    print(widget.session_code);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var provider = context.read<SurveyProvider>();
      provider.getSession(widget.session_code).then((_) {
        if (provider.session?.survey != null) {
          provider.getSurvey(provider.session!.code);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkSurveyCompletion() async {
    final storage = html.window.localStorage;
    String? surveyId =
        widget.session_code; // Assuming survey.id is same as session_code
    if (storage[surveyId] == 'completed') {
      setState(() {
        _isSurveyCompleted = true;
      });
    }
  }

  Future<void> _getDeviceId() async {
    String deviceId;

    if (kIsWeb) {
      deviceId = _getWebDeviceId();
    } else {
      final deviceInfo = DeviceInfoPlugin();
      try {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = 'android_${androidInfo.id}';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = 'ios_${iosInfo.identifierForVendor}';
        } else {
          deviceId = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
        }
      } catch (e) {
        deviceId = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
      }
    }

    setState(() {
      _deviceId = deviceId;
    });
  }

  String _getWebDeviceId() {
    try {
      final storage = html.window.localStorage;
      String? storedId = storage['device_id'];

      if (storedId != null && storedId.isNotEmpty) {
        return storedId;
      }

      final newId = 'web_${_generateWebFingerprint()}';
      storage['device_id'] = newId;
      return newId;
    } catch (e) {
      return 'web_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  String _generateWebFingerprint() {
    final userAgent = html.window.navigator.userAgent;
    final language = html.window.navigator.language;
    final platform = html.window.navigator.platform;
    final screenResolution =
        '${html.window.screen?.width}x${html.window.screen?.height}';

    final fingerprint =
        '·userAgent·${userAgent}·language·${language}·platform·${platform}·screenResolution·${screenResolution}';

    int hash = 0;
    for (int i = 0; i < fingerprint.length; i++) {
      hash = ((hash << 5) - hash) + fingerprint.codeUnitAt(i);
      hash = hash & hash;
    }

    return hash.abs().toString();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SurveyProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : managePage(),
    );
  }

  Widget managePage() {
    var provider = Provider.of<SurveyProvider>(context);

    if (_isSurveyCompleted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green[400]),
              const SizedBox(height: 24),
              Text(
                "Siz ushbu so'rovnomani tugatdingiz!",
                // Message indicating survey completion
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else if (provider.isSessionExpired) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_filled_rounded,
                  size: 80,
                  color: Colors.orange[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Bu so'rovnoma tugagan",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Afsuski, ushbu so'rovnoma muddati tugagan yoki faol emas.",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else if (provider.session == null || provider.survey?.id == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return buildSurveyContent(provider);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[50]!, Colors.green[100]!],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[500],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Muvaffaqiyatli yakunlandi!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'So\'rovnoma muvaffaqiyatli yuborildi. Ishtirokingiz uchun rahmat!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.green[600]!, Colors.green[400]!],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Clear all form data
                      setState(() {
                        answers.clear();
                        selectedFaculty.clear();
                        selectedDepartment.clear();
                        selectedTeacher.clear();
                        _isSurveyCompleted = true;
                        html.window.localStorage[widget.session_code] =
                        'completed'; // Store completion in localStorage
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Yopish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSurveyContent(SurveyProvider provider) {
    if (provider.survey == null) {
      return const Center(child: Text("So'rovnoma topilmadi"));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;
        double maxWidth = isDesktop ? 800 : double.infinity;

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              controller: _scrollController, // Add controller here
              padding: EdgeInsets.all(isDesktop ? 40 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Survey Header Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 32 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (provider.session?.groupName != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.group_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    provider.session!.groupName!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          Text(
                            provider.survey?.title ?? "So'rovnoma",
                            style: TextStyle(
                              fontSize: isDesktop ? 32 : 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          if (provider.survey?.description != null &&
                              provider.survey!.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              provider.survey!.description!,
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : 15,
                                color: Colors.white.withOpacity(0.95),
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${provider.survey?.questionsList?.length ?? 0} ta savol',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Questions
                  if (provider.survey?.questionsList != null &&
                      provider.survey!.questionsList!.isNotEmpty)
                    ...provider.survey!.questionsList!.asMap().entries.map((
                        entry,
                        ) {
                      int index = entry.key;
                      var question = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: buildQuestionCard(
                          question,
                          index + 1,
                          isDesktop,
                        ),
                      );
                    }).toList()
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Savollar topilmadi",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Submit Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.green[600]!, Colors.green[400]!],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSurveyCompleted
                          ? null
                          : () {
                        _submitSurvey(provider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 20 : 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Tasdiqlab yuborish',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildQuestionCard(question, int number, bool isDesktop) {
    bool needsDropdown =
        question.isTeacher == true || question.isDepartment == true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 28 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Number & Text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isDesktop ? 36 : 32,
                  height: isDesktop ? 36 : 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[400]!],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              question.text ?? '',
                              style: TextStyle(
                                fontSize: isDesktop ? 18 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                          if (question.isRequired == true)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Majburiy',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Badges
                      if (question.isTeacher == true ||
                          question.isDepartment == true) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (question.isTeacher == true)
                              _buildBadge(
                                'O\'qituvchi',
                                Icons.person_rounded,
                                Colors.green,
                              ),
                            if (question.isDepartment == true)
                              _buildBadge(
                                'Kafedra',
                                Icons.business_rounded,
                                Colors.orange,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Dropdowns for Faculty, Department, Teacher
            if (needsDropdown) ...[
              buildDropdownSection(question),
              const SizedBox(height: 20),
              Divider(color: Colors.grey[200], thickness: 1),
              const SizedBox(height: 20),
            ],

            // Question Input based on type
            if (question.questionType == 'single')
              buildSingleChoice(question, isDesktop)
            else if (question.questionType == 'multiple')
              buildMultipleChoice(question, isDesktop)
            else if (question.questionType == 'text')
                buildTextInput(question, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[200]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownSection(question) {
    int questionId = question.id?.toInt() ?? 0;

    // Only show dropdowns if isDepartment OR isTeacher is true
    bool showDepartmentDropdown = question.isDepartment == true;
    bool showTeacherDropdown = question.isTeacher == true;

    if (!showDepartmentDropdown && !showTeacherDropdown) {
      return const SizedBox.shrink(); // Don't show anything
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ma\'lumotlarni tanlang (ixtiyoriy):',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),

        // Faculty Dropdown (Always show if dropdowns are needed)
        FacultyDropdown(
          value: selectedFaculty[questionId],
          onChanged: (item) {
            // Save scroll position before setState
            final scrollPosition = _scrollController.hasClients
                ? _scrollController.position.pixels
                : 0.0;

            setState(() {
              if (item != null) {
                selectedFaculty[questionId] = item;
              } else {
                selectedFaculty.remove(questionId);
              }
              selectedDepartment.remove(questionId);
              selectedTeacher.remove(questionId);
            });

            // Restore scroll position after rebuild
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(scrollPosition);
              }
            });
          },
        ),

        if (selectedFaculty[questionId] != null) ...[
          const SizedBox(height: 16),

          // Department Dropdown (Show if isDepartment OR isTeacher is true)
          DepartmentDropdown(
            facultyId: selectedFaculty[questionId]!['id'],
            value: selectedDepartment[questionId],
            onChanged: (item) {
              // Save scroll position before setState
              final scrollPosition = _scrollController.hasClients
                  ? _scrollController.position.pixels
                  : 0.0;

              setState(() {
                if (item != null) {
                  selectedDepartment[questionId] = item;
                } else {
                  selectedDepartment.remove(questionId);
                }
                selectedTeacher.remove(questionId);
              });

              // Restore scroll position after rebuild
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(scrollPosition);
                }
              });
            },
          ),
        ],

        // Teacher Dropdown (Only show if isTeacher is true AND department is selected)
        if (showTeacherDropdown && selectedDepartment[questionId] != null) ...[
          const SizedBox(height: 16),
          TeacherDropdown(
            departmentId: selectedDepartment[questionId]!['id'],
            value: selectedTeacher[questionId],
            onChanged: (item) {
              // Save scroll position before setState
              final scrollPosition = _scrollController.hasClients
                  ? _scrollController.position.pixels
                  : 0.0;

              setState(() {
                if (item != null) {
                  selectedTeacher[questionId] = item;
                } else {
                  selectedTeacher.remove(questionId);
                }
              });

              // Restore scroll position after rebuild
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(scrollPosition);
                }
              });
            },
          ),
        ],
      ],
    );
  }

  Widget buildSingleChoice(question, bool isDesktop) {
    if (question.optionsList == null || question.optionsList!.isEmpty) {
      return _buildEmptyState("Variantlar topilmadi");
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: question.optionsList!.map<Widget>((option) {
          bool isSelected = answers[question.id?.toInt()] == option.id?.toInt();
          return Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[50] : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: RadioListTile<int>(
              title: Text(
                option.text ?? '',
                style: TextStyle(
                  fontSize: isDesktop ? 15 : 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.blue[700] : Colors.grey[800],
                ),
              ),
              value: option.id?.toInt() ?? 0,
              groupValue: answers[question.id?.toInt()],
              onChanged: (value) {
                setState(() {
                  answers[question.id?.toInt()] = value;
                });
              },
              activeColor: Colors.blue[600],
              contentPadding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : 16,
                vertical: 4,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildMultipleChoice(question, bool isDesktop) {
    if (question.optionsList == null || question.optionsList!.isEmpty) {
      return _buildEmptyState("Variantlar topilmadi");
    }

    List<int> selectedOptions =
        (answers[question.id?.toInt()] as List<int>?) ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: question.optionsList!.map<Widget>((option) {
          bool isSelected = selectedOptions.contains(option.id?.toInt());
          return Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green[50] : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.green[300]! : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: CheckboxListTile(
              title: Text(
                option.text ?? '',
                style: TextStyle(
                  fontSize: isDesktop ? 15 : 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.green[700] : Colors.grey[800],
                ),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  List<int> updatedList = List.from(selectedOptions);
                  if (value == true) {
                    updatedList.add(option.id?.toInt() ?? 0);
                  } else {
                    updatedList.remove(option.id?.toInt());
                  }
                  answers[question.id?.toInt()] = updatedList;
                });
              },
              activeColor: Colors.green[600],
              checkColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : 16,
                vertical: 4,
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildTextInput(question, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        maxLines: 5,
        style: TextStyle(
          fontSize: isDesktop ? 15 : 14,
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          hintText: 'Sizning fikringiz yoki taklifingiz...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.all(isDesktop ? 20 : 16),
        ),
        onChanged: (value) {
          setState(() {
            if (value.trim().isNotEmpty) {
              answers[question.id?.toInt()] = value;
            } else {
              answers.remove(question.id?.toInt());
            }
          });
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }

  Map<String, dynamic> _buildSubmitJson(SurveyProvider provider) {
    List<Map<String, dynamic>> answersList = [];

    provider.survey?.questionsList?.forEach((question) {
      int questionId = question.id?.toInt() ?? 0;
      Map<String, dynamic> answerData = {"question": questionId};

      // Add answer based on question type
      if (question.questionType == 'single') {
        if (answers[questionId] != null) {
          answerData["option"] = answers[questionId];
        }
      } else if (question.questionType == 'multiple') {
        if (answers[questionId] != null && answers[questionId] is List) {
          answerData["options"] = answers[questionId];
        }
      } else if (question.questionType == 'text') {
        if (answers[questionId] != null &&
            answers[questionId].toString().trim().isNotEmpty) {
          answerData["text_answer"] = answers[questionId];
        }
      }

      if (question.isTeacher == true && selectedTeacher[questionId] != null) {
        answerData["teacher_name"] = selectedTeacher[questionId]!['name'];
        answerData["teacher_id"] = selectedTeacher[questionId]!['id']
            .toString();
      }

      // Add department info ONLY if selected
      if ((question.isDepartment == true || question.isTeacher == true) &&
          selectedDepartment[questionId] != null) {
        answerData["department_name"] = selectedDepartment[questionId]!['name'];
        answerData["department_id"] = selectedDepartment[questionId]!['id']
            .toString();
      }

      answersList.add(answerData);
    });
    return {"device_id": _deviceId ?? 'unknown_device', "answers": answersList};
  }

  Future<void> _submitSurvey(SurveyProvider provider) async {
    List<String> errors = [];
    print(answers);
    // Validate required questions
    provider.survey?.questionsList?.forEach((question) {
      print(question.isRequired);
      if (question.isRequired!) {
        int qId = question.id?.toInt() ?? 0;
        var answer = answers[qId];

        if (question.questionType == 'text') {
          print("ishladi 1");

          if (answer == null || answer.toString().trim().isEmpty) {
            print("ishlad 2i");
            errors.add(question.text ?? 'Savol');
          }
        } else if (question.questionType == 'multiple') {
          // For multiple choice, check if list exists and has items
          if (answer == null || (answer is List && answer.isEmpty)) {
            errors.add(question.text ?? 'Savol');
          }
        } else {
          if (answer == null) {
            errors.add(question.text ?? 'Savol');
          }
        }
      }
    });

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Iltimos, barcha majburiy savollarni to\'ldiring',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final jsonData = _buildSubmitJson(provider);
    final jsonString = jsonEncode(jsonData);

    print('=== SUBMIT JSON ===');
    print(jsonString);
    print('==================');

    var response = await provider.submit(jsonString, widget.session_code);

    if (response) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'So\'rovnoma yuborishda xatolik!',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}