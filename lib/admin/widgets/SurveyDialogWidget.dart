import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/surveys_model.dart';
import '../../models/users_model.dart';

class SurveyDialogWidget extends StatefulWidget {
  final SurveyData? data;
  final Function(SurveyData)? onSave;
  final UsersModel? owners;

  const SurveyDialogWidget({super.key, this.data, this.onSave, this.owners});

  @override
  State<SurveyDialogWidget> createState() => _SurveyDialogWidgetState();
}

class _SurveyDialogWidgetState extends State<SurveyDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  UserData? selectedOwner;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.data?.title ?? '');
    descriptionController = TextEditingController(text: widget.data?.description ?? '');

    if (widget.data?.owner != null && widget.owners?.dataListList != null) {
      try {
        selectedOwner = widget.owners!.dataListList!.firstWhere(
              (element) => element.id == widget.data!.owner,
        );
      } catch (_) {
        selectedOwner = null;
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 24),

                // Mas'ul shaxs (Dropdown)
                _buildLabel("Ma'sul shaxs"),
                DropdownSearch<UserData>(
                  items: (f, p) => widget.owners?.dataListList ?? [],
                  selectedItem: selectedOwner,
                  itemAsString: (UserData u) => u.username ?? "Noma'lum",
                  compareFn: (item, selectedItem) => item.id == selectedItem.id,
                  onChanged: (value) => setState(() => selectedOwner = value),
                  decoratorProps: _dropdownDecoration(),
                  popupProps: _popupDecoration(),
                  validator: (value) => value == null ? "Iltimos, mas'ulni tanlang" : null,
                ),
                const SizedBox(height: 20),

                // Sarlavha
                _buildLabel("Sarlavha"),
                TextFormField(
                  controller: titleController,
                  decoration: _inputDecoration("Mavzuni kiriting", Icons.edit_note),
                  validator: (v) => v!.isEmpty ? "Sarlavha bo'sh bo'lmasin" : null,
                ),
                const SizedBox(height: 20),

                // Tavsif
                _buildLabel("Tavsif"),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: _inputDecoration("Batafsil ma'lumot...", Icons.description_outlined),
                  validator: (v) => v!.isEmpty ? "Tavsif bo'sh bo'lmasin" : null,
                ),
                const SizedBox(height: 32),

                // Tugmalar
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Yordamchi Widgetlar ---

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(widget.data == null ? Icons.add : Icons.edit, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        Text(
          widget.data == null ? "Yangi so'rovnoma" : "Tahrirlash",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 22),
      filled: true,
      fillColor: Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      errorStyle: const TextStyle(height: 0.8),
    );
  }

  DropDownDecoratorProps _dropdownDecoration() {
    return DropDownDecoratorProps(
      decoration: _inputDecoration("Tanlang", Icons.person_outline),
    );
  }

  PopupProps<UserData> _popupDecoration() {
    return PopupProps.menu(
      showSearchBox: true,
      // : BorderRadius.circular(16),
      searchFieldProps: TextFieldProps(
        decoration: _inputDecoration("Qidirish...", Icons.search),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Saqlash", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate() && selectedOwner != null) {
      final newData = SurveyData(
        id: widget.data?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        owner: int.tryParse(selectedOwner!.id.toString()),
      );

      if (widget.onSave != null) widget.onSave!(newData);
      Navigator.pop(context);
    }
  }
}