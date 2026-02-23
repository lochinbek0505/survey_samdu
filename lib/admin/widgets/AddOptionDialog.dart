import 'package:flutter/material.dart';

class AddOptionDialog extends StatefulWidget {

  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const AddOptionDialog({super.key, this.initialData, required this.onSave});

  @override
  State<AddOptionDialog> createState() => _AddOptionDialogState();
}

class _AddOptionDialogState extends State<AddOptionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late TextEditingController _orderController;
  late String _eduType;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.initialData?['text'] ?? '',
    );
    _orderController = TextEditingController(
      text: widget.initialData?['order']?.toString() ?? '0',
    );
    _eduType = widget.initialData?['edu_type'] ?? 'none';
  }

  @override
  void dispose() {
    _textController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialData == null
            ? 'Variant qo\'shish'
            : 'Variantni tahrirlash',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Variant matni *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Tartib raqamini kiriting';
                  if (int.tryParse(value) == null)
                    return 'Faqat raqam kiriting';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _eduType,
                decoration: const InputDecoration(
                  labelText: 'Ta\'lim turi *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Yo\'q')),
                  DropdownMenuItem(value: 'lesson', child: Text('Fan')),
                  DropdownMenuItem(value: 'department', child: Text('Kafedra')),
                  DropdownMenuItem(
                    value: 'teacher',
                    child: Text('O\'qituvchi'),
                  ),
                ],
                onChanged: (value) => setState(() => _eduType = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final optionData = {
                'text': _textController.text,
                'order': int.parse(_orderController.text),
                'edu_type': _eduType,
              };

              // Map<String, dynamic> sifatida qaytarish
              widget.onSave(Map<String, dynamic>.from(optionData));

              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Saqlash'),
        ),
      ],
    );
  }
}
