import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/SessionProvider.dart';

class LessonDropdown extends StatefulWidget {
  final int facultyId;
  final List<Map<String, dynamic>>? value; // Single → List
  final Function(List<Map<String, dynamic>>?) onChanged; // Single → List

  const LessonDropdown({
    Key? key,
    required this.facultyId,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<LessonDropdown> createState() => _LessonDropdownState();
}

class _LessonDropdownState extends State<LessonDropdown> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _lessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  @override
  void didUpdateWidget(LessonDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.facultyId != widget.facultyId) {
      _loadLessons();
    }
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    try {
      var provider = context.read<SurveyProvider>();
      var result = await provider.getSubjects("?parent=${widget.facultyId}");

      if (result != null && result.itemsList != null) {
        setState(() {
          _lessons = result.itemsList!
              .map((e) => {
            'id': e.id,
            'name': e.name,
            'code': e.code,
          })
              .toList();
        });
      }
    } catch (e) {
      print("Fanlarni yuklashda xatolik: $e");
      setState(() => _lessons = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _LessonMultiSelectDialog(
        lessons: _lessons,
        selectedLessons: widget.value ?? [],
        onConfirm: (selected) {
          widget.onChanged(selected);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = (widget.value != null && widget.value!.isNotEmpty)
        ? '${widget.value!.length} ta fan tanlandi'
        : "Fanni tanlang";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoading
          ? const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      )
          : InkWell(
        onTap: _showMultiSelectDialog,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(Icons.book_rounded, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: (widget.value != null && widget.value!.isNotEmpty)
                        ? Colors.black87
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.purple[700]),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonMultiSelectDialog extends StatefulWidget {
  final List<Map<String, dynamic>> lessons;
  final List<Map<String, dynamic>> selectedLessons;
  final Function(List<Map<String, dynamic>>) onConfirm;

  const _LessonMultiSelectDialog({
    required this.lessons,
    required this.selectedLessons,
    required this.onConfirm,
  });

  @override
  State<_LessonMultiSelectDialog> createState() =>
      _LessonMultiSelectDialogState();
}

class _LessonMultiSelectDialogState extends State<_LessonMultiSelectDialog> {
  late List<Map<String, dynamic>> _selected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedLessons);
  }

  bool _isSelected(Map<String, dynamic> lesson) {
    return _selected.any((s) => s['id'] == lesson['id']);
  }

  void _toggleSelection(Map<String, dynamic> lesson) {
    setState(() {
      if (_isSelected(lesson)) {
        _selected.removeWhere((s) => s['id'] == lesson['id']);
      } else {
        _selected.add(lesson);
      }
    });
  }

  List<Map<String, dynamic>> get _filteredLessons {
    if (_searchQuery.isEmpty) return widget.lessons;
    return widget.lessons
        .where((l) =>
        (l['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.book_rounded, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text(
                  'Fanlarni tanlang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Qidirish...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selected.length} ta tanlandi',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredLessons.length,
                itemBuilder: (context, index) {
                  final lesson = _filteredLessons[index];
                  final isSelected = _isSelected(lesson);
                  return CheckboxListTile(
                    title: Text(lesson['name'] ?? ''),
                    subtitle: lesson['code'] != null
                        ? Text(lesson['code'])
                        : null,
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(lesson),
                    activeColor: Colors.purple[700],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Bekor qilish'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onConfirm(_selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Saqlash'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}