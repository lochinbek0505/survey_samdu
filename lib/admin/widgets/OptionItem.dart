import 'package:flutter/material.dart';

import '../../models/question_model.dart';

class OptionItem extends StatelessWidget {
  final OptionModel option;
  final String optionNumber;
  final String questionType;
  final int level;
  final int surveyId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddChildQuestion;

  const OptionItem({
    super.key,
    required this.option,
    required this.optionNumber,
    required this.questionType,
    required this.level,
    required this.surveyId,
    required this.onEdit,
    required this.onDelete,
    required this.onAddChildQuestion,
  });

  MaterialColor _getLevelColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[level % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = option.childQuestions.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasChildren ? _getLevelColor() : Colors.grey[300]!,
          width: hasChildren ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: hasChildren ? _getLevelColor().withOpacity(0.05) : null,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              optionNumber,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getLevelColor(),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              questionType == 'single'
                  ? Icons.radio_button_unchecked
                  : Icons.check_box_outline_blank,
              color: _getLevelColor(),
            ),
          ],
        ),
        title: Text(
          option.text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (option.eduType != 'none')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school, size: 14, color: Colors.amber[800]),
                      const SizedBox(width: 4),
                      Text(
                        _getEduTypeText(option.eduType),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                ),
              if (hasChildren)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getLevelColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link, size: 14, color: _getLevelColor()[700]),
                      const SizedBox(width: 4),
                      Text(
                        '${option.childQuestions.length} ta bog\'langan savol',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getLevelColor()[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
              case 'add_child':
                onAddChildQuestion();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'add_child',
              child: Row(
                children: [
                  Icon(Icons.add_link, size: 18),
                  SizedBox(width: 8),
                  Text('Savol biriktirish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('O\'chirish', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEduTypeText(String type) {
    switch (type) {
      case 'lesson':
        return 'Fan';
      case 'department':
        return 'Kafedra';
      case 'teacher':
        return 'O\'qituvchi';
      default:
        return type;
    }
  }
}
