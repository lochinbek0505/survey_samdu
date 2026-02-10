import 'package:flutter/material.dart';

import 'DropdownContainer.dart';
import 'TeacherSearchDialogNew.dart';

class TeacherDropdown extends StatelessWidget {
  final dynamic departmentId;
  final Map<String, dynamic>? value;
  final Function(Map<String, dynamic>?) onChanged;

  const TeacherDropdown({
    Key? key,
    required this.departmentId,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownContainer(
      label: 'O\'qituvchi',
      icon: Icons.person_rounded,
      value: value?['name'],
      onTap: () => _showTeacherDialog(context),
    );
  }

  void _showTeacherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => TeacherSearchDialogNew(
        departmentId: departmentId,
        selectedValue: value?['name'],
        onSelected: (item) {
          onChanged(item);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}
