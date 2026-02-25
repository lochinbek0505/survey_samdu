import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/SessionProvider.dart';

class DepartmentSearchDialog extends StatefulWidget {
  final dynamic facultyId;
  final List<Map<String, dynamic>>? selectedValues; // Changed from String?
  final Function(List<Map<String, dynamic>>) onSelected; // Changed to List

  const DepartmentSearchDialog({
    required this.facultyId,
    this.selectedValues,
    required this.onSelected,
  });

  @override
  State<DepartmentSearchDialog> createState() =>
      _DepartmentSearchDialogState();
}

class _DepartmentSearchDialogState extends State<DepartmentSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allDepartments = [];
  List<Map<String, dynamic>> _filteredDepartments = [];
  late List<Map<String, dynamic>> _selectedDepartments;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDepartments = List.from(widget.selectedValues ?? []);
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final provider = context.read<SurveyProvider>();
      final result = await provider.getKafedra(widget.facultyId);

      if (!mounted) return;

      if (result != null && result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _allDepartments = result.items!
              .map((d) => {'id': d.id, 'name': d.name ?? 'Noma\'lum'})
              .toList();
          _filteredDepartments = _allDepartments;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Kafedralar topilmadi';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Xatolik: $e';
        _isLoading = false;
      });
      print('Department loading error: $e');
    }
  }

  void _filterDepartments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDepartments = _allDepartments;
      } else {
        _filteredDepartments = _allDepartments
            .where(
              (dept) =>
              dept['name']!.toLowerCase().contains(query.toLowerCase()),
        )
            .toList();
      }
    });
  }

  bool _isSelected(Map<String, dynamic> dept) {
    return _selectedDepartments.any((s) => s['id'] == dept['id']);
  }

  void _toggleSelection(Map<String, dynamic> dept) {
    setState(() {
      if (_isSelected(dept)) {
        _selectedDepartments.removeWhere((s) => s['id'] == dept['id']);
      } else {
        _selectedDepartments.add(dept);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.business_rounded, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kafedra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search Field
            if (!_isLoading && _errorMessage == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Qidirish...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: _filterDepartments,
                ),
              ),

            // Selected count
            if (!_isLoading && _errorMessage == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_selectedDepartments.length} ta tanlandi',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            if (!_isLoading && _errorMessage == null) const SizedBox(height: 8),

            // Content
            Flexible(child: _buildContent()),

            // Action Buttons
            if (!_isLoading && _errorMessage == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                        child: const Text('Bekor qilish'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            widget.onSelected(_selectedDepartments),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Saqlash'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadDepartments();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredDepartments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Hech narsa topilmadi',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _filteredDepartments.length,
      itemBuilder: (context, index) {
        final dept = _filteredDepartments[index];
        bool isSelected = _isSelected(dept);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.orange[300]! : Colors.grey[200]!,
              width: 1.5,
            ),
          ),
          child: CheckboxListTile(
            title: Text(
              dept['name']!,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.orange[700] : Colors.grey[800],
              ),
            ),
            value: isSelected,
            onChanged: (_) => _toggleSelection(dept),
            activeColor: Colors.orange[700],
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}