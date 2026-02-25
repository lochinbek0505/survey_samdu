import 'package:flutter/material.dart';

import 'DepartmentSearchDialog.dart';
import 'DropdownContainer.dart';

class DepartmentDropdown extends StatelessWidget {
  final dynamic facultyId;
  final List<Map<String, dynamic>>? value; // Single → List
  final Function(List<Map<String, dynamic>>?) onChanged; // Single → List

  const DepartmentDropdown({
    Key? key,
    required this.facultyId,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Display selected count or placeholder
    final displayText = (value != null && value!.isNotEmpty)
        ? '${value!.length} ta kafedra tanlandi'
        : null;

    return DropdownContainer(
      label: 'Kafedra',
      icon: Icons.business_rounded,
      value: displayText,
      onTap: () => _showDepartmentDialog(context),
    );
  }

  void _showDepartmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => DepartmentSearchDialog(
        facultyId: facultyId,
        selectedValues: value, // Changed from selectedValue
        onSelected: (items) {
          onChanged(items);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}