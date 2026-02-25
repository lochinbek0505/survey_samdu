import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../../models/question_model.dart';
import '../providers/SessionProvider.dart';
import '../widgets/DepartmentDropdown.dart';
import '../widgets/FacultyDropdown.dart';
import '../widgets/LessonDropdown.dart';
import '../widgets/TeacherDropdown.dart';

class SurveyPage extends StatefulWidget {
  String session_code;

  SurveyPage({super.key, required this.session_code});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  // Asosiy javoblar: {questionId: value}
  Map<int, dynamic> answers = {};

  // Har bir option uchun edu ma'lumotlari (MULTI-SELECT)
  // Format: {questionId: {optionId: {faculty: [], department: [], teacher/lesson: []}}}
  Map<int, Map<int, Map<String, List<Map<String, dynamic>>>>> optionEduData =
      {};

  List<QuestionModel> displayedQuestions = [];

  String? _deviceId;
  bool _isSurveyCompleted = false;
  bool _hasError = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getDeviceId();
    _checkSurveyCompletion();
    print(widget.session_code);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var provider = context.read<SurveyProvider>();
      provider
          .getSession(widget.session_code)
          .then((_) {
            if (provider.session?.survey != null) {
              provider.getSurvey(provider.session!.code).then((_) {
                _initializeDisplayedQuestions(provider);
              });
            }
          })
          .catchError((error) {
            setState(() {
              _hasError = true;
            });
          });
    });
  }

  void _initializeDisplayedQuestions(SurveyProvider provider) {
    setState(() {
      // Faqat parent_option == null bo'lgan (asosiy) savollarni qo'shamiz
      displayedQuestions =
          provider.survey?.questions
              ?.where((q) => q.parentOption == null)
              .toList() ??
          [];
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkSurveyCompletion() async {
    final storage = html.window.localStorage;
    String? surveyId = widget.session_code;
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
        'userAgent:${userAgent}|language:${language}|platform:${platform}|screen:${screenResolution}';

    int hash = 0;
    for (int i = 0; i < fingerprint.length; i++) {
      hash = ((hash << 5) - hash) + fingerprint.codeUnitAt(i);
      hash = hash & hash;
    }

    return hash.abs().toString();
  }

  // Child questionlarni qo'shish/o'chirish
  void _handleOptionSelection(dynamic option, bool isSelected) {
    if (option.childQuestions.isNotEmpty) {
      setState(() {
        if (isSelected) {
          // Child questionlarni qo'shamiz
          for (var childQuestion in option.childQuestions) {
            // Agar bu child question allaqachon mavjud bo'lmasa
            if (!displayedQuestions.any((q) => q.id == childQuestion.id)) {
              // Parent question indexini topamiz
              int parentIndex = displayedQuestions.indexWhere(
                (q) => q.options?.any((opt) => opt.id == option.id) ?? false,
              );
              if (parentIndex != -1) {
                // Parent questiondan keyin qo'shamiz
                displayedQuestions.insert(parentIndex + 1, childQuestion);
              }
            }
          }
        } else {
          // Child questionlarni o'chiramiz
          for (var childQuestion in option.childQuestions) {
            displayedQuestions.removeWhere((q) => q.id == childQuestion.id);
            // Child questionning javoblarini ham o'chiramiz
            answers.remove(childQuestion.id?.toInt());
            optionEduData.remove(childQuestion.id?.toInt());
          }
        }
      });
    }
  }

  // Group bo'yicha savollarni guruhlash
  Map<int, List<dynamic>> _groupQuestions() {
    Map<int, List<dynamic>> groupedQuestions = {};
    for (var question in displayedQuestions) {
      int groupId = question.group ?? 0;
      if (!groupedQuestions.containsKey(groupId)) {
        groupedQuestions[groupId] = [];
      }
      groupedQuestions[groupId]!.add(question);
    }
    return groupedQuestions;
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
    } else if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Xatolik: Ma'lumotlarni yuklashda muammo bo'ldi.",
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  var provider = context.read<SurveyProvider>();
                  provider.getSession(widget.session_code);
                });
              },
              child: const Text('Qaytadan urinib ko\'ring'),
            ),
          ],
        ),
      );
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
                      setState(() {
                        answers.clear();
                        optionEduData.clear();
                        displayedQuestions.clear();
                        _isSurveyCompleted = true;
                        html.window.localStorage[widget.session_code] =
                            'completed';
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

        // Savollarni guruhlaymiz
        Map<int, List<dynamic>> groupedQuestions = _groupQuestions();
        List<int> groupIds = groupedQuestions.keys.toList()..sort();

        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              controller: _scrollController,
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
                                  '${displayedQuestions.length} ta savol',
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

                  // Guruhlab savollarni chiqaramiz
                  if (displayedQuestions.isNotEmpty)
                    ...groupIds.map((groupId) {
                      List<dynamic> questionsInGroup =
                          groupedQuestions[groupId]!;
                      String groupName =
                          questionsInGroup.first.groupName ?? 'Umumiy';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Guruh nomi
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  color: Colors.blue[700],
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  groupName,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Guruh ichidagi savollar
                          ...questionsInGroup.asMap().entries.map((entry) {
                            int localIndex = entry.key;
                            var question = entry.value;
                            int globalNumber =
                                displayedQuestions.indexOf(question) + 1;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: buildQuestionCard(
                                question,
                                globalNumber,
                                isDesktop,
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 16),
                        ],
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
                      onPressed: () {
                        if (_isSurveyCompleted) {
                          return;
                        }

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
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

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

  // EDU_TYPE uchun MULTI-SELECT dropdown yaratish
  Widget buildDropdownForOption(
    question,
    option,
    int questionId,
    int optionId,
    bool isDesktop,
  ) {
    String eduType = option.eduType ?? 'none';

    if (eduType == 'none') {
      return const SizedBox.shrink();
    }

    // Initialize nested maps agar mavjud bo'lmasa (LISTLAR bilan)
    optionEduData[questionId] ??= {};
    optionEduData[questionId]![optionId] ??= {};

    var currentData = optionEduData[questionId]![optionId]!;

    // Agar listlar mavjud bo'lmasa, bo'sh list yaratamiz
    currentData['faculty'] ??= [];
    currentData['department'] ??= [];
    currentData['teacher'] ??= [];
    currentData['lesson'] ??= [];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.blue[50]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge ko'rsatish
          Wrap(
            spacing: 8,
            children: [
              if (eduType == 'teacher')
                _buildBadge('O\'qituvchi', Icons.person_rounded, Colors.green),
              if (eduType == 'department')
                _buildBadge('Kafedra', Icons.business_rounded, Colors.orange),
              if (eduType == 'lesson')
                _buildBadge('Fan', Icons.menu_book_rounded, Colors.blue),
            ],
          ),
          const SizedBox(height: 16),

          // TEACHER uchun: Faculty (multi) → Department (multi) → Teacher (multi)
          if (eduType == 'teacher') ...[
            FacultyDropdown(
              value: currentData['faculty'] as List<Map<String, dynamic>>?,
              onChanged: (items) {
                _preserveScrollAndUpdate(() {
                  currentData['faculty'] = items ?? [];
                  currentData['department'] = [];
                  currentData['teacher'] = [];
                });
              },
            ),
            if ((currentData['faculty'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              DepartmentDropdown(
                facultyId: (currentData['faculty'] as List).first['id'],
                value: currentData['department'] as List<Map<String, dynamic>>?,
                onChanged: (items) {
                  _preserveScrollAndUpdate(() {
                    currentData['department'] = items ?? [];
                    currentData['teacher'] = [];
                  });
                },
              ),
            ],
            if ((currentData['department'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              TeacherDropdown(
                departmentId: (currentData['department'] as List).first['id'],
                value: currentData['teacher'] as List<Map<String, dynamic>>?,
                onChanged: (items) {
                  _preserveScrollAndUpdate(() {
                    currentData['teacher'] = items ?? [];
                  });
                },
              ),
            ],
          ],

          // DEPARTMENT uchun: Faculty (multi) → Department (multi)
          if (eduType == 'department') ...[
            FacultyDropdown(
              value: currentData['faculty'] as List<Map<String, dynamic>>?,
              onChanged: (items) {
                _preserveScrollAndUpdate(() {
                  currentData['faculty'] = items ?? [];
                  currentData['department'] = [];
                });
              },
            ),
            if ((currentData['faculty'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              DepartmentDropdown(
                facultyId: (currentData['faculty'] as List).first['id'],
                value: currentData['department'] as List<Map<String, dynamic>>?,
                onChanged: (items) {
                  _preserveScrollAndUpdate(() {
                    currentData['department'] = items ?? [];
                  });
                },
              ),
            ],
          ],

          // LESSON uchun: Faculty (multi) → Subject (multi)
          if (eduType == 'lesson') ...[
            FacultyDropdown(
              value: currentData['faculty'] as List<Map<String, dynamic>>?,
              onChanged: (items) {
                _preserveScrollAndUpdate(() {
                  currentData['faculty'] = items ?? [];
                  currentData['lesson'] = [];
                });
              },
            ),
            if ((currentData['faculty'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              LessonDropdown(
                facultyId: (currentData['faculty'] as List).first['id'],
                value: currentData['lesson'] as List<Map<String, dynamic>>?,
                onChanged: (items) {
                  _preserveScrollAndUpdate(() {
                    currentData['lesson'] = items ?? [];
                  });
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  // Scroll pozitsiyasini saqlash
  void _preserveScrollAndUpdate(VoidCallback updateFunction) {
    final scrollPosition = _scrollController.hasClients
        ? _scrollController.position.pixels
        : 0.0;

    setState(() {
      updateFunction();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(scrollPosition);
      }
    });
  }

  Widget buildSingleChoice(question, bool isDesktop) {
    if (question.options == null || question.options!.isEmpty) {
      return _buildEmptyState("Variantlar topilmadi");
    }

    int questionId = question.id?.toInt() ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: question.options!.map<Widget>((option) {
          int optionId = option.id?.toInt() ?? 0;
          bool isSelected = answers[questionId] == optionId;

          return Column(
            children: [
              Container(
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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? Colors.blue[700] : Colors.grey[800],
                    ),
                  ),
                  value: optionId,
                  groupValue: answers[questionId],
                  onChanged: (value) {
                    // Oldingi tanlovning child questionlarini o'chiramiz
                    if (answers[questionId] != null) {
                      var previousOption = question.options!.firstWhere(
                        (opt) => opt.id?.toInt() == answers[questionId],
                        orElse: () => OptionModel(
                          id: 0,
                          text: '',
                          order: 0,
                          question: 0,
                          eduType: 'none',
                          childQuestions: [],
                        ),
                      );
                      if (previousOption.id != 0) {
                        _handleOptionSelection(previousOption, false);
                      }
                    }

                    setState(() {
                      answers[questionId] = value;
                    });

                    // Yangi tanlovning child questionlarini qo'shamiz
                    _handleOptionSelection(option, true);
                  },
                  activeColor: Colors.blue[600],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 20 : 16,
                    vertical: 4,
                  ),
                ),
              ),
              // Dropdown agar kerak bo'lsa
              if (isSelected)
                buildDropdownForOption(
                  question,
                  option,
                  questionId,
                  optionId,
                  isDesktop,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget buildMultipleChoice(question, bool isDesktop) {
    if (question.options == null || question.options!.isEmpty) {
      return _buildEmptyState("Variantlar topilmadi");
    }

    int questionId = question.id?.toInt() ?? 0;
    List<int> selectedOptions = (answers[questionId] as List<int>?) ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: question.options!.map<Widget>((option) {
          int optionId = option.id?.toInt() ?? 0;
          bool isSelected = selectedOptions.contains(optionId);

          return Column(
            children: [
              Container(
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
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? Colors.green[700] : Colors.grey[800],
                    ),
                  ),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      List<int> updatedList = List.from(selectedOptions);
                      if (value == true) {
                        updatedList.add(optionId);
                        _handleOptionSelection(option, true);
                      } else {
                        updatedList.remove(optionId);
                        // Agar option o'chirilsa, uning edu_data ham o'chirilsin
                        optionEduData[questionId]?.remove(optionId);
                        _handleOptionSelection(option, false);
                      }
                      answers[questionId] = updatedList;
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
              ),
              // Dropdown agar kerak bo'lsa
              if (isSelected)
                buildDropdownForOption(
                  question,
                  option,
                  questionId,
                  optionId,
                  isDesktop,
                ),
            ],
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

  // YANGI SUBMIT JSON YARATISH (MULTI-SELECT)
  Map<String, dynamic> _buildSubmitJson(SurveyProvider provider) {
    print('📦 JSON yaratish boshlandi...');

    Map<String, dynamic> finalJson = {
      "device_id": _deviceId ?? 'unknown_device',
      "answers": _createAnswersList(),
    };

    print('✅ JSON tayyor: ${jsonEncode(finalJson)}');
    return finalJson;
  }

  List<Map<String, dynamic>> _createAnswersList() {
    List<Map<String, dynamic>> answersList = [];

    print(
      '🔄 ${displayedQuestions.length} ta savol uchun javoblar tekshirilmoqda...',
    );

    for (var question in displayedQuestions) {
      int questionId = question.id?.toInt() ?? 0;
      String questionType = question.questionType ?? 'single';

      print('  ❓ Savol #$questionId ($questionType)');

      Map<String, dynamic>? answerData = _createAnswerForQuestion(
        questionId: questionId,
        questionType: questionType,
        question: question,
      );

      if (answerData != null) {
        answersList.add(answerData);
        print('    ✓ Javob qo\'shildi');
      } else {
        print('    ⚠ Javob topilmadi');
      }
    }

    print('📊 Jami ${answersList.length} ta javob yig\'ildi');
    return answersList;
  }

  Map<String, dynamic>? _createAnswerForQuestion({
    required int questionId,
    required String questionType,
    required dynamic question,
  }) {
    Map<String, dynamic> answerData = {"question": questionId};

    switch (questionType) {
      case 'text':
        return _handleTextAnswer(answerData, questionId);

      case 'single':
        return _handleSingleChoiceAnswer(answerData, questionId, question);

      case 'multiple':
        return _handleMultipleChoiceAnswer(answerData, questionId, question);

      default:
        print('    ⚠ Noma\'lum savol turi: $questionType');
        return null;
    }
  }

  Map<String, dynamic>? _handleTextAnswer(
    Map<String, dynamic> answerData,
    int questionId,
  ) {
    var textAnswer = answers[questionId];

    if (textAnswer != null && textAnswer.toString().trim().isNotEmpty) {
      answerData["text_answer"] = textAnswer.toString().trim();
      print(
        '    📝 Matn javobi: "${textAnswer.toString().substring(0, textAnswer.toString().length > 20 ? 20 : textAnswer.toString().length)}..."',
      );
      return answerData;
    }

    return null;
  }

  Map<String, dynamic>? _handleSingleChoiceAnswer(
    Map<String, dynamic> answerData,
    int questionId,
    dynamic question,
  ) {
    var selectedOptionId = answers[questionId];

    if (selectedOptionId != null && selectedOptionId is int) {
      print('    🔘 Tanlangan variant: $selectedOptionId');

      var optionData = _buildOptionData(
        questionId: questionId,
        optionId: selectedOptionId,
        question: question,
      );

      if (optionData != null) {
        answerData["selected_options"] = [optionData];
        return answerData;
      }
    }

    return null;
  }

  Map<String, dynamic>? _handleMultipleChoiceAnswer(
    Map<String, dynamic> answerData,
    int questionId,
    dynamic question,
  ) {
    var selectedOptionIds = answers[questionId];

    if (selectedOptionIds != null && selectedOptionIds is List<int>) {
      print('    ☑️  Tanlangan variantlar soni: ${selectedOptionIds.length}');

      List<Map<String, dynamic>> selectedOptions = [];

      for (int optionId in selectedOptionIds) {
        var optionData = _buildOptionData(
          questionId: questionId,
          optionId: optionId,
          question: question,
        );

        if (optionData != null) {
          selectedOptions.add(optionData);
          print('      ✓ Variant #$optionId qo\'shildi');
        }
      }

      if (selectedOptions.isNotEmpty) {
        answerData["selected_options"] = selectedOptions;
        return answerData;
      }
    }

    return null;
  }

  Map<String, dynamic>? _buildOptionData({
    required int questionId,
    required int optionId,
    required dynamic question,
  }) {
    Map<String, dynamic> optionData = {"option": optionId};

    var eduItems = _getEduItemsForOption(
      questionId: questionId,
      optionId: optionId,
      question: question,
    );

    if (eduItems != null && eduItems.isNotEmpty) {
      optionData["edu_items"] = eduItems;
      print('        📚 EDU ma\'lumotlar qo\'shildi: ${eduItems.length} ta');
    }

    return optionData;
  }

  // MULTI-SELECT EDU ma'lumotlarini olish
  List<Map<String, String>>? _getEduItemsForOption({
    required int questionId,
    required int optionId,
    required QuestionModel question,
  }) {
    var savedEduData = optionEduData[questionId]?[optionId];

    if (savedEduData == null || savedEduData.isEmpty) {
      return null;
    }

    var option = question.options?.firstWhere(
      (opt) => opt.id?.toInt() == optionId,
      orElse: () => OptionModel(
        id: 0,
        text: '',
        order: 0,
        question: 0,
        eduType: 'none',
        childQuestions: [],
      ),
    );

    // Agar option topilmasa, null tekshirish
    if (option?.id == null) {
      print('        ⚠ Variant topilmadi: #$optionId');
      return null;
    }

    if (option == null) {
      print('        ⚠ Variant topilmadi: #$optionId');
      return null;
    }

    String eduType = option.eduType ?? 'none';
    print('        🏷️  EDU turi: $eduType');

    return _extractEduItemsByType(eduType, savedEduData);
  }

  // MULTI-SELECT uchun EDU ma'lumotlarini extract qilish
  List<Map<String, String>>? _extractEduItemsByType(
    String eduType,
    Map<String, List<Map<String, dynamic>>> savedData,
  ) {
    List<Map<String, String>> eduItems = [];

    switch (eduType) {
      case 'teacher':
        // Har bir tanlangan o'qituvchi uchun
        List<Map<String, dynamic>> teachers = savedData['teacher'] ?? [];
        for (var teacher in teachers) {
          eduItems.add({
            "edu_id": teacher['id'].toString(),
            "edu_text": teacher['name'].toString(),
          });
          print('          👤 O\'qituvchi: ${teacher['name']}');
        }
        break;

      case 'department':
        // Har bir tanlangan kafedra uchun
        List<Map<String, dynamic>> departments = savedData['department'] ?? [];
        for (var dept in departments) {
          eduItems.add({
            "edu_id": dept['id'].toString(),
            "edu_text": dept['name'].toString(),
          });
          print('          🏢 Kafedra: ${dept['name']}');
        }
        break;

      case 'lesson':
        // Har bir tanlangan fan uchun
        List<Map<String, dynamic>> lessons = savedData['lesson'] ?? [];
        for (var lesson in lessons) {
          eduItems.add({
            "edu_id": lesson['id'].toString(),
            "edu_text": lesson['name'].toString(),
          });
          print('          📖 Fan: ${lesson['name']}');
        }
        break;

      case 'none':
        return null;

      default:
        print('          ⚠ Noma\'lum EDU turi: $eduType');
        return null;
    }

    return eduItems.isNotEmpty ? eduItems : null;
  }

  Future<void> _submitSurvey(SurveyProvider provider) async {
    print('\n🚀 So\'rovnoma yuborish boshlandi...\n');

    List<String> errors = _validateRequiredQuestions();

    if (errors.isNotEmpty) {
      print('❌ Validatsiya xatosi: ${errors.length} ta savol to\'ldirilmagan');
      _showValidationError();
      return;
    }

    print('✅ Validatsiya muvaffaqiyatli\n');

    final jsonData = _buildSubmitJson(provider);
    final jsonString = jsonEncode(jsonData);

    print('\n📤 Yuborilayotgan JSON:');
    print(jsonString);
    print('\n');

    var response = await provider.submit(jsonString, widget.session_code);

    if (response) {
      print('✅ So\'rovnoma muvaffaqiyatli yuborildi!');
      _showSuccessDialog();
    } else {
      print('❌ Server xatosi!');
      _showErrorSnackbar();
    }
  }

  List<String> _validateRequiredQuestions() {
    List<String> errors = [];

    for (var question in displayedQuestions) {
      if (question.isRequired != true) continue;

      int qId = question.id?.toInt() ?? 0;
      var answer = answers[qId];

      bool isInvalid = false;

      if (question.questionType == 'text') {
        isInvalid = answer == null || answer.toString().trim().isEmpty;
      } else if (question.questionType == 'multiple') {
        isInvalid = answer == null || (answer is List && answer.isEmpty);
      } else {
        isInvalid = answer == null;
      }

      if (isInvalid) {
        errors.add(question.text ?? 'Savol');
      }
    }

    return errors;
  }

  void _showValidationError() {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackbar() {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
