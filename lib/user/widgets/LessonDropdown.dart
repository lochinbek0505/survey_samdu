import 'dart:async'; // Qidiruvni kechiktirish (debounce) uchun

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/SessionProvider.dart';

class LessonDropdown extends StatefulWidget {
  final List<Map<String, dynamic>>? value;
  final Function(List<Map<String, dynamic>>?) onChanged;

  const LessonDropdown({Key? key, this.value, required this.onChanged})
    : super(key: key);

  @override
  State<LessonDropdown> createState() => _LessonDropdownState();
}

class _LessonDropdownState extends State<LessonDropdown> {
  void _showMultiSelectDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, anim1, anim2) => _LessonMultiSelectDialog(
        selectedLessons: widget.value ?? [],
        onConfirm: (selected) {
          widget.onChanged(selected);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = (widget.value != null && widget.value!.isNotEmpty)
        ? '${widget.value!.length} ta fan tanlandi'
        : "Fanlarni tanlang";

    return InkWell(
      onTap: _showMultiSelectDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
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
    );
  }
}

class _LessonMultiSelectDialog extends StatefulWidget {
  final List<Map<String, dynamic>> selectedLessons;
  final Function(List<Map<String, dynamic>>) onConfirm;

  const _LessonMultiSelectDialog({
    required this.selectedLessons,
    required this.onConfirm,
  });

  @override
  State<_LessonMultiSelectDialog> createState() =>
      _LessonMultiSelectDialogState();
}

class _LessonMultiSelectDialogState extends State<_LessonMultiSelectDialog> {
  late List<Map<String, dynamic>> _selected;
  List<Map<String, dynamic>> _lessons = [];
  bool _isLoading = false;
  Timer? _debounce; // Serverga so'rovlarni kamaytirish uchun

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedLessons);
    _loadLessons(''); // Dastlabki yuklash
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Asosiy yuklash va qidiruv funksiyasi
  Future<void> _loadLessons(String query) async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<SurveyProvider>();

      // Query parametrlarni shakllantirish
      String urlParams = "?search=$query";

      final result = await provider.getSubjects(urlParams);

      if (result != null && result.itemsList != null) {
        setState(() {
          _lessons = result.itemsList!
              .map((e) => {'id': e.id, 'name': e.name, 'code': e.code})
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Xatolik: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadLessons(query);
    });
  }

  bool _isSelected(Map<String, dynamic> lesson) {
    return _selected.any((s) => s['id'] == lesson['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Fanlarni tanlang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Qidirish...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _lessons.isEmpty
                  ? const Center(child: Text("Fanlar topilmadi"))
                  : ListView.builder(
                      itemCount: _lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _lessons[index];
                        final isSelected = _isSelected(lesson);
                        return CheckboxListTile(
                          title: Text(lesson['name'] ?? ''),
                          subtitle: Text(lesson['code'] ?? ''),
                          value: isSelected,
                          onChanged: (_) {
                            setState(() {
                              if (isSelected) {
                                _selected.removeWhere(
                                  (s) => s['id'] == lesson['id'],
                                );
                              } else {
                                _selected.add(lesson);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            const Divider(),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Bekor qilish'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(_selected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                  ),
                  child: const Text(
                    'Saqlash',
                    style: TextStyle(color: Colors.white),
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
