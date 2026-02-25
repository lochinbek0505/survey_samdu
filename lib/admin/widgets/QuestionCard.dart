import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/question_model.dart';
import '../provider/QuestionsProvider.dart';
import 'AddOptionDialog.dart';
import 'AddOptionPage.dart';
import 'AddQuestionPage.dart';
import 'EditQuestionPage.dart';
import 'OptionItem.dart';

class QuestionCard extends StatefulWidget {
  final QuestionModel question;
  final String questionNumber;
  final int level;
  final int surveyId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddOption;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.level,
    required this.surveyId,
    required this.onEdit,
    required this.onDelete,
    required this.onAddOption,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool isExpanded = true;

  MaterialColor _getLevelColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[widget.level % colors.length];
  }

  Color _getLevelBackgroundColor() {
    final colors = [
      Colors.blue[50]!,
      Colors.green[50]!,
      Colors.orange[50]!,
      Colors.purple[50]!,
      Colors.teal[50]!,
    ];
    return colors[widget.level % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();
    final levelBgColor = _getLevelBackgroundColor();

    return Container(
      margin: EdgeInsets.only(left: widget.level * 24.0, bottom: 16),
      child: Column(
        children: [
          Card(
            elevation: widget.level == 0 ? 3 : 2,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: widget.level > 0
                  ? BorderSide(color: levelColor, width: 2)
                  : BorderSide.none,
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: levelBgColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isExpanded
                          ? Radius.zero
                          : const Radius.circular(12),
                      bottomRight: isExpanded
                          ? Radius.zero
                          : const Radius.circular(12),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.level > 0) ...[
                          Icon(
                            Icons.subdirectory_arrow_right,
                            color: levelColor,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                        ],
                        CircleAvatar(
                          backgroundColor: levelColor,
                          child: Text(
                            widget.questionNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      widget.question.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildChip(
                            _getQuestionTypeText(widget.question.questionType),
                            Colors.purple,
                          ),
                          if (widget.question.isRequired)
                            _buildChip('Majburiy', Colors.red),
                          _buildChip(
                            'Guruh: ${widget.question.group}',
                            Colors.orange,
                          ),
                          if (widget.level > 0)
                            _buildChip('Bog\'langan savol', levelColor),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                          onPressed: () =>
                              setState(() => isExpanded = !isExpanded),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                widget.onEdit();
                                break;
                              case 'delete':
                                widget.onDelete();
                                break;
                              case 'add_option':
                                widget.onAddOption();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Tahrirlash'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'add_option',
                              child: Row(
                                children: [
                                  Icon(Icons.add, size: 20),
                                  SizedBox(width: 8),
                                  Text('Variant qo\'shish'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'O\'chirish',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded && widget.question.options.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Javob variantlari:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.question.options.asMap().entries.map((entry) {
                          int optionIndex = entry.key;
                          OptionModel option = entry.value;
                          return OptionItem(
                            option: option,
                            optionNumber:
                                '${widget.questionNumber}.${optionIndex + 1}',
                            questionType: widget.question.questionType,
                            level: widget.level,
                            surveyId: widget.surveyId,
                            onEdit: () => _showEditOptionDialog(option),
                            onDelete: () => _showDeleteOptionDialog(option),
                            onAddChildQuestion: () =>
                                _showAddChildQuestionDialog(option),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isExpanded)
            ...widget.question.options.asMap().entries.expand((entry) {
              int optionIndex = entry.key;
              OptionModel option = entry.value;
              return option.childQuestions.asMap().entries.map((childEntry) {
                int childIndex = childEntry.key;
                QuestionModel childQuestion = childEntry.value;
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: QuestionCard(
                    question: childQuestion,
                    questionNumber:
                        '${widget.questionNumber}.${optionIndex + 1}.${childIndex + 1}',
                    level: widget.level + 1,
                    surveyId: widget.surveyId,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditQuestionPage(
                            question: childQuestion,
                            surveyId: widget.surveyId,
                          ),
                        ),
                      );
                    },
                    onDelete: () => _showDeleteQuestionDialog(childQuestion),
                    onAddOption: () => _showAddOptionDialog(childQuestion),
                  ),
                );
              });
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildChip(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getQuestionTypeText(String type) {
    switch (type) {
      case 'single':
        return 'Bir tanlovli';
      case 'multiple':
        return 'Ko\'p tanlovli';
      case 'text':
        return 'Matnli';
      default:
        return type;
    }
  }

  void _showEditOptionDialog(OptionModel option) {
    showDialog(
      context: context,
      builder: (ctx) => AddOptionDialog(
        initialData: {
          'text': option.text,
          'order': option.order,
          'edu_type': option.eduType,
        },
        onSave: (optionData) {
          final updatedJson = {
            "id": option.id,
            "text": optionData['text'],
            "order": optionData['order'],
            "edu_type": optionData['edu_type'],
            // "question": option.questionId, // agar modelda bo‘lsa
          };

          // API YO'Q: faqat local/provider update
          // Provider.of<QuestionsProvider>(context, listen: false).updateOptionLocal(
          //   optionId: option.id,
          //   newText: optionData['text'],
          //   newOrder: optionData['order'],
          //   newEduType: optionData['edu_type'],
          // );

          // Yakuniy JSON (API ga yubormaymiz)
          // ignore: avoid_print
          print("EDIT OPTION JSON: $updatedJson");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Variant yangilandi (local)')),
          );
        },
      ),
    );
  }

  void _showDeleteOptionDialog(OptionModel option) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Ushbu variantni o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              var provider = Provider.of<QuestionsProvider>(
                context,
                listen: false,
              );
              provider.deleteOption(context, option.id, widget.surveyId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Variant o\'chirildi')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  void _showAddChildQuestionDialog(OptionModel option) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionPage(
          surveyId: widget.surveyId,
          parentOptionId: option.id,
        ),
      ),
    );
  }

  void _showDeleteQuestionDialog(QuestionModel question) {
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
              var provide = Provider.of<QuestionsProvider>(
                context,
                listen: false,
              );
              await provide.deleteQuestion(
                context,
                question.id,
                question.survey!.toInt(),
              );
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  void _showAddOptionDialog(QuestionModel question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOptionPage(questionId: question.id),
      ),
    );
  }
}
