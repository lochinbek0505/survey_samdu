import 'package:flutter/material.dart';

import 'DepartmentSearchDialog.dart';
import 'DropdownContainer.dart';

class DepartmentDropdown extends StatelessWidget {
  final dynamic facultyId;
  final Map<String, dynamic>? value;
  final Function(Map<String, dynamic>?) onChanged;

  const DepartmentDropdown({
    Key? key,
    required this.facultyId,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownContainer(
      label: 'Kafedra',
      icon: Icons.business_rounded,
      value: value?['name'],
      onTap: () => _showDepartmentDialog(context),
    );
  }

  void _showDepartmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => DepartmentSearchDialog(
        facultyId: facultyId,
        selectedValue: value?['name'],
        onSelected: (item) {
          onChanged(item);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}
