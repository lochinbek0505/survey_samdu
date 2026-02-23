import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/question_model.dart';
import '../provider/QuestionsProvider.dart';
import 'AddOptionDialog.dart';

class EditQuestionPage extends StatefulWidget {
  final QuestionModel question;
  final int surveyId;

  const EditQuestionPage({
    super.key,
    required this.question,
    required this.surveyId,
  });

  @override
  State<EditQuestionPage> createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _textController;
  late TextEditingController _orderController;

  late String _questionType;
  late bool _isRequired;
  late int? _selectedGroupId;

  // Edit uchun options local copy (Map formatda)
  late List<Map<String, dynamic>> _options;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question.text);
    _orderController = TextEditingController(
      text: widget.question.order.toString(),
    );
    _questionType = widget.question.questionType;
    _isRequired = widget.question.isRequired;
    _selectedGroupId = widget.question.group;

    _options = widget.question.options
        .map(
          (o) => {
            'id': o.id,
            'text': o.text,
            'order': o.order,
            'edu_type': o.eduType,
            'child_questions': o.childQuestions.map((c) => c.toJson()).toList(),
          },
        )
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuestionsProvider>(
        context,
        listen: false,
      ).getQuestionGroups();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestionsProvider>(context);
    final isTextType = _questionType == 'text';

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: const Text(
          'Savolni tahrirlash',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Savol matni *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.question_answer),
              ),
              maxLines: 3,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Savol matnini kiriting'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _questionType,
              decoration: const InputDecoration(
                labelText: 'Savol turi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'single', child: Text('Bir tanlovli')),
                DropdownMenuItem(
                  value: 'multiple',
                  child: Text('Ko\'p tanlovli'),
                ),
                DropdownMenuItem(value: 'text', child: Text('Matnli javob')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _questionType = value;

                  // agar text turiga o'tsa, variantlar yo'q bo'lishi kerak
                  if (_questionType == 'text') {
                    _options = [];
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Majburiy savol'),
              subtitle: const Text('Javob berish shart'),
              value: _isRequired,
              onChanged: (value) => setState(() => _isRequired = value),
              secondary: const Icon(Icons.priority_high),
            ),
            const SizedBox(height: 16),

            // Guruh tanlash dropdown
            DropdownButtonFormField<int>(
              value: _selectedGroupId,
              decoration: const InputDecoration(
                labelText: 'Savol guruhi *',
                hintText: 'Guruhni tanlang',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group_work),
              ),
              items: provider.questionGroups.map((group) {
                return DropdownMenuItem<int>(
                  value: group.id,
                  child: Text(group.name),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedGroupId = value),
              validator: (value) => value == null ? 'Guruhni tanlang' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _orderController,
              decoration: const InputDecoration(
                labelText: 'Tartib raqami *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Tartib raqamini kiriting';
                if (int.tryParse(value) == null) return 'Faqat raqam kiriting';
                return null;
              },
            ),
            const SizedBox(height: 24),

            if (!isTextType) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Javob variantlari',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add),
                    label: const Text('Variant qo\'shish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_options.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Hozircha variantlar yo\'q',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(option['text']),
                      subtitle: Text(
                        'Tartib: ${option['order']} | Ta\'lim turi: ${_getEduTypeText(option['edu_type'])}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _editOption(index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteOption(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              const SizedBox(height: 24),
            ],

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Saqlash',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addOption() {
    showDialog(
      context: context,
      builder: (ctx) => AddOptionDialog(
        onSave: (optionData) {
          setState(() => _options.add(Map<String, dynamic>.from(optionData)));
        },
      ),
    );
  }

  void _editOption(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AddOptionDialog(
        initialData: _options[index],
        onSave: (optionData) {
          setState(() {
            final existingId = _options[index]['id'];
            _options[index] = Map<String, dynamic>.from(optionData);
            if (existingId != null) _options[index]['id'] = existingId;
          });
        },
      ),
    );
  }

  void _deleteOption(int index) {
    setState(() => _options.removeAt(index));
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questionType != 'text' && _options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamida bitta variant bo\'lishi kerak'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print(widget.question.parentOption);

    final editedQuestionJson = {
      "id": widget.question.id,
      "survey": widget.surveyId,
      "text": _textController.text,
      "question_type": _questionType,
      "is_required": _isRequired,
      "order": int.parse(_orderController.text),
      "group": _selectedGroupId,
      "parent_option": widget.question.parentOption,
      "options": _questionType == 'text' ? [] : _options,
    };
    print(editedQuestionJson);
    var provider = Provider.of<QuestionsProvider>(context, listen: false);
   await provider.updateQuestion(
      editedQuestionJson,
      context,
      widget.surveyId,
      widget.question.id,
    );

    Navigator.pop(context);
  }

  String _getEduTypeText(String type) {
    switch (type) {
      case 'lesson':
        return 'Fan';
      case 'department':
        return 'Kafedra';
      case 'teacher':
        return 'O\'qituvchi';
      case 'none':
        return 'Yo\'q';
      default:
        return type;
    }
  }
}
