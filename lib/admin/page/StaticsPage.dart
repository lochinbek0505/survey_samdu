import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_samdu/admin/provider/AdminProvider.dart';
import 'package:survey_samdu/models/session_list_model.dart';
import 'package:survey_samdu/models/statics_model.dart';

class StatisticsPage extends StatefulWidget {
  int index;

  StatisticsPage({super.key, required this.index});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DataList? _selectedSession;
  StaticsModel? _statistics;
  StaticsModel? _generalStatistics;
  bool _loading = false;
  bool _loadingGeneral = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var provider = Provider.of<AdminProvider>(context, listen: false);
      provider.getSessions(context);
      _loadGeneralStatistics();
    });
  }

  Future<void> _loadGeneralStatistics() async {
    setState(() {
      _loadingGeneral = true;
    });

    try {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final result = await provider.getStatics(widget.index, '',context);

      setState(() {
        _generalStatistics = result;
        _loadingGeneral = false;
      });
    } catch (e) {
      setState(() {
        _loadingGeneral = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Umumiy statistikani yuklashda xatolik: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadStatistics() async {
    if (_selectedSession == null) return;

    setState(() {
      _loading = true;
    });

    try {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final result = await provider.getStatics(
          widget.index,
          '?session=${_selectedSession!.id}',context
      );

      setState(() {
        _statistics = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'So\'rovnoma statistikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yangilash',
            onPressed: () {
              _loadGeneralStatistics();
              if (_selectedSession != null) {
                _loadStatistics();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Consumer<AdminProvider>(
                  builder: (context, provider, child) {
                    final sessions = provider.sessions.dataListList ?? [];
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<DataList>(
                            decoration: InputDecoration(
                              labelText: 'Sessiyani tanlang',
                              prefixIcon: const Icon(Icons.event),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            value: _selectedSession,
                            items: sessions.map((session) {
                              return DropdownMenuItem<DataList>(
                                value: session,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Guruh: ${session.groupName}' ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (DataList? value) {
                              setState(() {
                                _selectedSession = value;
                                _statistics = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _selectedSession == null || _loading
                              ? null
                              : _loadStatistics,
                          icon: _loading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.search),
                          label: Text(_loading ? 'Yuklanmoqda...' : 'Ko\'rish'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (_selectedSession != null) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedSession = null;
                        _statistics = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Filterni tozalash'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ],
              ],
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Agar session tanlangan bo'lsa, uning statistikasini ko'rsatamiz
    if (_selectedSession != null) {
      if (_loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_statistics == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Statistikani ko\'rish uchun "Ko\'rish" tugmasini bosing',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSessionInfoCard(),
          const SizedBox(height: 16),
          _buildSummaryCard(_statistics!),
          const SizedBox(height: 16),
          ..._buildQuestionCards(_statistics!),
        ],
      );
    }

    // Aks holda umumiy statistikani ko'rsatamiz
    if (_loadingGeneral) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_generalStatistics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Statistika yuklanmadi',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGeneralInfoCard(),
        const SizedBox(height: 16),
        _buildSummaryCard(_generalStatistics!),
        const SizedBox(height: 16),
        ..._buildQuestionCards(_generalStatistics!),
      ],
    );
  }

  Widget _buildGeneralInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UMUMIY STATISTIKA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Barcha sessiyalar',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Barcha ma\'lumotlar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.green[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SESSIYA STATISTIKASI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedSession!.name ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSessionInfoItem(
                    Icons.group,
                    'Guruh',
                    _selectedSession!.groupName ?? '',
                  ),
                ),
                Expanded(
                  child: _buildSessionInfoItem(
                    Icons.vpn_key,
                    'Kod',
                    _selectedSession!.code ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(StaticsModel statistics) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurple[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.poll, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statistics.surveyTitle ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Umumiy javoblar: ${statistics.totalResponses}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  Icons.question_answer,
                  'Savollar',
                  '${statistics.questionsList?.length ?? 0}',
                ),
                _buildSummaryItem(
                  Icons.people,
                  'Ishtirokchilar',
                  '${statistics.totalResponses}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  List<Widget> _buildQuestionCards(StaticsModel statistics) {
    return statistics.questionsList?.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildQuestionCard(question, index + 1),
      );
    }).toList() ??
        [];
  }

  Widget _buildQuestionCard(Questions question, int questionNumber) {
    if (question.questionType == 'text') {
      return _buildTextQuestionCard(question, questionNumber);
    }
    return _buildChoiceQuestionCard(question, questionNumber);
  }

  Widget _buildChoiceQuestionCard(Questions question, int questionNumber) {
    final total =
        question.resultsList?.fold<num>(
          0,
              (sum, result) => sum + (result.count ?? 0),
        ) ??
            0;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$questionNumber',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.questionText ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: question.questionType == 'multiple'
                        ? Colors.orange[100]
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    question.questionType == 'multiple'
                        ? 'Ko\'p tanlov'
                        : 'Bitta tanlov',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: question.questionType == 'multiple'
                          ? Colors.orange[800]
                          : Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if ((question.resultsList?.length ?? 0) > 0) ...[
              SizedBox(
                height: 250,
                child: _buildPieChart(question.resultsList!, total),
              ),
              const SizedBox(height: 20),
              ...question.resultsList!.map((result) {
                final percentage = total > 0
                    ? ((result.count! / total) * 100).toStringAsFixed(1)
                    : '0.0';
                return _buildResultItem(result, percentage);
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List<Results> results, num total) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: results.asMap().entries.map((entry) {
          final index = entry.key;
          final result = entry.value;
          final percentage = total > 0 ? (result.count! / total) * 100 : 0;

          return PieChartSectionData(
            color: colors[index % colors.length],
            value: result.count!.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultItem(Results result, String percentage) {
    // Teachers yoki departments mavjudligini tekshirish
    final hasTeachers = result.teachersList != null && result.teachersList!.isNotEmpty;
    final hasDepartments = result.departmentsList != null && result.departmentsList!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${result.count}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        title: Text(
          result.optionText ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '$percentage% (${result.count} ta javob)',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // O'qituvchilar bo'limi
                if (hasTeachers) ...[
                  Row(
                    children: [
                      Icon(Icons.person, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'O\'qituvchilar bo\'yicha:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...result.teachersList!.map((teacher) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                '${teacher.count}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teacher.teacherName ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${teacher.count} marta belgilandi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                // Departmentlar bo'limi
                if (hasDepartments) ...[
                  if (hasTeachers) const SizedBox(height: 16),
                  if (hasTeachers) Divider(color: Colors.grey[300]),
                  if (hasTeachers) const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.business, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Kafedra bo\'yicha:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...result.departmentsList!.map((department) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                '${department.count}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  department.departmentName ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${department.count} marta belgilandi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],

                // Agar hech narsa bo'lmasa
                if (!hasTeachers && !hasDepartments)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Qo\'shimcha ma\'lumot yo\'q',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextQuestionCard(Questions question, int questionNumber) {
    final responses = question.resultsList ?? [];
    int responseCount = 0;

    for (var response in responses) {
      responseCount += response.count?.toInt() ?? 0;
    }

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$questionNumber',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.questionText ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Matnli javob',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Jami javoblar: $responseCount',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            if (responses.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: responses.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final response = responses[index];
                  final hasTeachers = response.teachersList != null && response.teachersList!.isNotEmpty;
                  final hasDepartments = response.departmentsList != null && response.departmentsList!.isNotEmpty;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${response.count} ta',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                response.text ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),

                        // Teachers yoki Departments mavjud bo'lsa ko'rsatamiz
                        if (hasTeachers || hasDepartments) ...[
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey[300]),
                          const SizedBox(height: 12),

                          // O'qituvchilar
                          if (hasTeachers) ...[
                            Row(
                              children: [
                                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  'O\'qituvchilar:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...response.teachersList!.map((teacher) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 22),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${teacher.count}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        teacher.teacherName ?? '',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],

                          // Departmentlar
                          if (hasDepartments) ...[
                            if (hasTeachers) const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.business, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  'Kafedralar:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...response.departmentsList!.map((department) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 22),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${department.count}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        department.departmentName ?? '',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ],
                    ),
                  );
                },
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Hozircha javoblar yo\'q',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}