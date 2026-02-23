import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/QuestionsProvider.dart';
import 'AddOptionDialog.dart';

class AddQuestionPage extends StatefulWidget {
  final int surveyId;
  final int? parentOptionId;

  const AddQuestionPage({
    super.key,
    required this.surveyId,
    this.parentOptionId,
  });

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _orderController = TextEditingController();

  String _questionType = 'single';
  bool _isRequired = false;
  List<Map<String, dynamic>> _options = [];
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuestionsProvider>(context, listen: false).getQuestionGroups();
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

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          widget.parentOptionId == null
              ? 'Savol qo\'shish'
              : 'Bog\'langan savol qo\'shish',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.parentOptionId != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu savol variantga bog\'langan holda qo\'shiladi',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Savol matni *',
                hintText: 'Savolingizni kiriting',
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
              onChanged: (value) => setState(() => _questionType = value!),
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
                hintText: 'Masalan: 1',
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
            if (_questionType != 'text') ...[
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
                  int index = entry.key;
                  Map<String, dynamic> option = entry.value;
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
                onPressed: _submitQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Savolni saqlash',
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
        onSave: (optionData) => setState(() => _options.add(optionData)),
      ),
    );
  }

  void _editOption(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AddOptionDialog(
        initialData: _options[index],
        onSave: (optionData) => setState(() => _options[index] = optionData),
      ),
    );
  }

  void _deleteOption(int index) {
    setState(() => _options.removeAt(index));
  }

  Future<void> _submitQuestion() async {
    if (_formKey.currentState!.validate()) {
      if (_questionType != 'text' && _options.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kamida bitta variant qo\'shing'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final questionJson = {
        "survey": widget.surveyId,
        "text": _textController.text,
        "question_type": _questionType,
        "is_required": _isRequired,
        "order": int.parse(_orderController.text),
        "group": _selectedGroupId,
        "parent_option": widget.parentOptionId,
        "options": _options,
      };

      print(questionJson);
      final provider = Provider.of<QuestionsProvider>(context, listen: false);

      await provider.addQuestion(questionJson, context, widget.surveyId);

      Navigator.pop(context);
    }
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