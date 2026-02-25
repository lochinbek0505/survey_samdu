import 'package:flutter/material.dart';

import 'DropdownContainer.dart';
import 'TeacherSearchDialogNew.dart';

class TeacherDropdown extends StatelessWidget {
  final dynamic departmentId;
  final List<Map<String, dynamic>>? value; // Single → List
  final Function(List<Map<String, dynamic>>?) onChanged; // Single → List

  const TeacherDropdown({
    Key? key,
    required this.departmentId,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Display selected count or placeholder
    final displayText = (value != null && value!.isNotEmpty)
        ? '${value!.length} ta o\'qituvchi tanlandi'
        : null;

    return DropdownContainer(
      label: 'O\'qituvchi',
      icon: Icons.person_rounded,
      value: displayText,
      onTap: () => _showTeacherDialog(context),
    );
  }

  void _showTeacherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => TeacherSearchDialogNew(
        departmentId: departmentId,
        selectedValues: value, // Changed from selectedValue
        onSelected: (items) {
          onChanged(items);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}