import 'package:flutter/material.dart';

import '../../models/fakultet_model.dart';
import '../../service/AppConsts.dart';
import 'DropdownContainer.dart';
import 'SearchDialog.dart';

class FacultyDropdown extends StatelessWidget {
  final Map<String, dynamic>? value;
  final Function(Map<String, dynamic>?) onChanged;

  const FacultyDropdown({Key? key, this.value, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faculties = AppConsts.fakultetlar.dataListList ?? [];

    return DropdownContainer(
      label: 'Fakultet',
      icon: Icons.account_balance_rounded,
      value: value?['name'],
      onTap: () => _showFacultyDialog(context, faculties),
    );
  }

  void _showFacultyDialog(BuildContext context, List<Faculties> faculties) {
    showDialog(
      context: context,
      builder: (context) => SearchDialog(
        title: 'Fakultet',
        icon: Icons.account_balance_rounded,
        items: faculties
            .map((f) => {'id': f.id, 'name': f.name ?? ''})
            .toList(),
        selectedValue: value?['name'],
        onSelected: (item) {
          onChanged(item);
          Navigator.pop(context);
        },
      ),
    );
  }
}
