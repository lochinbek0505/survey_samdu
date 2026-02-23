
import 'package:flutter/material.dart';

class AddOptionPage extends StatefulWidget {
  final int questionId;

  const AddOptionPage({super.key, required this.questionId});

  @override
  State<AddOptionPage> createState() => _AddOptionPageState();
}

class _AddOptionPageState extends State<AddOptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _orderController = TextEditingController();
  String _eduType = 'none';

  @override
  void dispose() {
    _textController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: const Text(
          'Variant qo\'shish',
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
                labelText: 'Variant matni *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_fields),
              ),
              maxLines: 3,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Variant matnini kiriting'
                  : null,
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _eduType,
              decoration: const InputDecoration(
                labelText: 'Ta\'lim turi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Yo\'q')),
                DropdownMenuItem(value: 'lesson', child: Text('Fan')),
                DropdownMenuItem(value: 'department', child: Text('Kafedra')),
                DropdownMenuItem(value: 'teacher', child: Text('O\'qituvchi')),
              ],
              onChanged: (value) => setState(() => _eduType = value!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitOption,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Variantni saqlash',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitOption() {
    if (_formKey.currentState!.validate()) {
      final optionJson = {
        "text": _textController.text,
        "order": int.parse(_orderController.text),
        "question": widget.questionId,
        "edu_type": _eduType,
      };

      // API YO'Q: faqat print
      // ignore: avoid_print
      print('ADD Option JSON: $optionJson');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Variant muvaffaqiyatli qo\'shildi'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
