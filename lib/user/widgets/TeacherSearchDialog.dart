import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/SessionProvider.dart';

class _TeacherSearchDialogState extends State<TeacherSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _teachers = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
    if (!mounted) return; // ✅ Tekshiruv

    if (isNewSearch) {
      setState(() {
        _teachers.clear();
        _currentPage = 1;
        _isLoading = true;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final provider = context.read<SurveyProvider>();
    String link =
        '?department=${widget.departmentId}&type=teacher&page=$_currentPage&limit=20';
    if (_searchQuery.isNotEmpty) {
      link += '&search=$_searchQuery';
    }

    final result = await provider.getEmployee(widget.departmentId, link);

    if (!mounted) return; // ✅ API dan keyin tekshiruv

    if (result != null && result.itemsList != null) {
      setState(() {
        _teachers.addAll(
          result.itemsList!
              .map(
                (emp) => {
                  'id': emp.id,
                  'name': emp.fullName ?? '',
                  'position': emp.staffPosition ?? '',
                },
              )
              .toList(),
        );
        _totalPages = result.pagination?.pageCount?.toInt() ?? 1;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreTeachers() async {
    if (!mounted) return; // ✅ Tekshiruv

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    final provider = context.read<SurveyProvider>();
    String link =
        '?department=${widget.departmentId}&type=teacher&page=$_currentPage&limit=20';
    if (_searchQuery.isNotEmpty) {
      link += '&search=$_searchQuery';
    }

    final result = await provider.getEmployee(widget.departmentId, link);

    if (!mounted) return; // ✅ API dan keyin tekshiruv

    if (result != null && result.itemsList != null) {
      setState(() {
        _teachers.addAll(
          result.itemsList!
              .map(
                (emp) => {
                  'id': emp.id,
                  'name': emp.fullName ?? '',
                  'position': emp.staffPosition ?? '',
                },
              )
              .toList(),
        );
        _isLoadingMore = false;
      });
    } else {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _loadTeachers(isNewSearch: true);
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
                    onPressed: () {
                      if (mounted) Navigator.pop(context); // ✅ Tekshiruv
                    },
                  ),
                ],
              ),
            ),

            // Search Field
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

            // Teachers List
            Flexible(
              child: _isLoading && _teachers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _teachers.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hech narsa topilmadi',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
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
                        bool isSelected =
                            widget.selectedValue == teacher['name'];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue[50]
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue[300]!
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              teacher['name']!,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.blue[700]
                                    : Colors.grey[800],
                              ),
                            ),
                            subtitle: Text(
                              teacher['position']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Colors.blue[700],
                                  )
                                : null,
                            onTap: () {
                              widget.onSelected(teacher);
                              if (mounted)
                                Navigator.pop(context); // ✅ Tekshiruv
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Teacher Search Dialog (Yangi struktura - pagination bilan)

// Dropdown Container Widget

class TeacherSearchDialog extends StatefulWidget {
  final dynamic departmentId;
  final String? selectedValue;
  final Function(Map<String, dynamic>) onSelected;

  const TeacherSearchDialog({
    required this.departmentId,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  State<TeacherSearchDialog> createState() => _TeacherSearchDialogState();
}
