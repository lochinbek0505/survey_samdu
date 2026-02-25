import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/SessionProvider.dart';

class TeacherSearchDialogNew extends StatefulWidget {
  final dynamic departmentId;
  final List<Map<String, dynamic>>? selectedValues; // Changed from String?
  final Function(List<Map<String, dynamic>>) onSelected; // Changed to List

  const TeacherSearchDialogNew({
    required this.departmentId,
    this.selectedValues,
    required this.onSelected,
  });

  @override
  State<TeacherSearchDialogNew> createState() =>
      _TeacherSearchDialogNewState();
}

class _TeacherSearchDialogNewState extends State<TeacherSearchDialogNew> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _teachers = [];
  late List<Map<String, dynamic>> _selectedTeachers;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedTeachers = List.from(widget.selectedValues ?? []);
    _loadTeachers();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMoreTeachers();
      }
    }
  }

  Future<void> _loadTeachers({bool isNewSearch = false}) async {
    if (!mounted) return;

    setState(() {
      if (isNewSearch) {
        _teachers.clear();
        _currentPage = 1;
      }
      _isLoading = isNewSearch || _currentPage == 1;
      _errorMessage = null;
    });

    try {
      final provider = context.read<SurveyProvider>();
      String link =
          '?department=${widget.departmentId}&type=teacher&page=$_currentPage&limit=20';
      if (_searchQuery.isNotEmpty) {
        link += '&search=$_searchQuery';
      }

      final result = await provider.getEmployee(widget.departmentId, link);

      if (!mounted) return;

      if (result != null && result.itemsList != null) {
        setState(() {
          _teachers.addAll(
            result.itemsList!
                .map(
                  (emp) => {
                'id': emp.id,
                'name': emp.fullName ?? 'Noma\'lum',
                'position': emp.staffPosition ?? '',
              },
            )
                .toList(),
          );
          _totalPages = result.pagination?.pageCount?.toInt() ?? 1;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'O\'qituvchilar topilmadi';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Xatolik: $e';
        _isLoading = false;
      });
      print('Teacher loading error: $e');
    }
  }

  Future<void> _loadMoreTeachers() async {
    if (!mounted || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final provider = context.read<SurveyProvider>();
      String link =
          '?department=${widget.departmentId}&type=teacher&page=$_currentPage&limit=20';
      if (_searchQuery.isNotEmpty) {
        link += '&search=$_searchQuery';
      }

      final result = await provider.getEmployee(widget.departmentId, link);

      if (!mounted) return;

      if (result != null && result.itemsList != null) {
        setState(() {
          _teachers.addAll(
            result.itemsList!
                .map(
                  (emp) => {
                'id': emp.id,
                'name': emp.fullName ?? 'Noma\'lum',
                'position': emp.staffPosition ?? '',
              },
            )
                .toList(),
          );
          _isLoadingMore = false;
        });
      } else {
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      print('Load more error: $e');
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _loadTeachers(isNewSearch: true);
  }

  bool _isSelected(Map<String, dynamic> teacher) {
    return _selectedTeachers.any((s) => s['id'] == teacher['id']);
  }

  void _toggleSelection(Map<String, dynamic> teacher) {
    setState(() {
      if (_isSelected(teacher)) {
        _selectedTeachers.removeWhere((s) => s['id'] == teacher['id']);
      } else {
        _selectedTeachers.add(teacher);
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
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_rounded, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'O\'qituvchi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
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
            if (!_isLoading || _teachers.isNotEmpty)
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
                  onChanged: _onSearchChanged,
                ),
              ),

            // Selected count
            if (!_isLoading || _teachers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_selectedTeachers.length} ta tanlandi',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            if (!_isLoading || _teachers.isNotEmpty) const SizedBox(height: 8),

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
                        onPressed: () => widget.onSelected(_selectedTeachers),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue[700],
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
    if (_isLoading && _teachers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null && _teachers.isEmpty) {
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
                onPressed: () => _loadTeachers(isNewSearch: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      );
    }

    if (_teachers.isEmpty) {
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
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: _teachers.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _teachers.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final teacher = _teachers[index];
        bool isSelected = _isSelected(teacher);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
              width: 1.5,
            ),
          ),
          child: CheckboxListTile(
            title: Text(
              teacher['name']!,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.blue[700] : Colors.grey[800],
              ),
            ),
            subtitle: teacher['position']!.isNotEmpty
                ? Text(
              teacher['position']!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            )
                : null,
            value: isSelected,
            onChanged: (_) => _toggleSelection(teacher),
            activeColor: Colors.blue[700],
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}