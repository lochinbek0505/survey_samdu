import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_samdu/admin/provider/QuestionsProvider.dart';
import 'package:survey_samdu/models/question_model.dart';
import 'package:survey_samdu/models/surveys_model.dart';

import '../widgets/AddOptionPage.dart';
import '../widgets/AddQuestionPage.dart';
import '../widgets/EditQuestionPage.dart';
import '../widgets/QuestionCard.dart';

class QuestionsPage extends StatefulWidget {
  SurveyData data;

  QuestionsPage({super.key, required this.data});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuestionsProvider>(
        context,
        listen: false,
      ).getQuestions(widget.data.id!.toInt());
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<QuestionsProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          widget.data.title!,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddQuestionDialog(context, null);
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.questions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Hozircha savollar yo\'q',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddQuestionDialog(context, null);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Savol qo\'shish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.questions
                  .where((q) => q.parentOption == null)
                  .length,
              itemBuilder: (context, index) {
                var mainQuestions = provider.questions
                    .where((q) => q.parentOption == null)
                    .toList();
                var item = mainQuestions[index];
                return QuestionCard(
                  question: item,
                  questionNumber: '${index + 1}',
                  level: 0,
                  surveyId: widget.data.id!.toInt(),
                  onEdit: () => _showEditQuestionPage(context, item),
                  onDelete: () => _showDeleteConfirmation(context, item),
                  onAddOption: () => _showAddOptionDialog(context, item),
                );
              },
            ),
    );
  }

  void _showAddQuestionDialog(BuildContext context, int? parentOptionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionPage(
          surveyId: widget.data.id!.toInt(),
          parentOptionId: parentOptionId,
        ),
      ),
    );
  }

  void _showEditQuestionPage(BuildContext context, QuestionModel question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditQuestionPage(
          question: question,
          surveyId: widget.data.id!.toInt(),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, QuestionModel question) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Ushbu savolni o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(ctx);

              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Perform async operation
              var provide = Provider.of<QuestionsProvider>(
                context,
                listen: false,
              );
              await provide.deleteQuestion(
                context,
                question.id,
                widget.data.id!.toInt(),
              );

              // Use the saved instance instead of looking it up after async
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Savol o\'chirildi')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  void _showAddOptionDialog(BuildContext context, QuestionModel question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOptionPage(questionId: question.id),
      ),
    );
  }
}
