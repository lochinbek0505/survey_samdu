import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/SessionProvider.dart';

class LessonDropdown extends StatefulWidget {
  final int facultyId;
  final Map<String, dynamic>? value;
  final Function(Map<String, dynamic>?) onChanged;

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
      // Faculty ID orqali fanlarni yuklash
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

  @override
  Widget build(BuildContext context) {
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
          : DropdownButton<Map<String, dynamic>>(
        value: widget.value,
        hint: Row(
          children: [
            Icon(Icons.book_rounded, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              "Fanni tanlang",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.purple[700]),
        items: _lessons.map((lesson) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: lesson,
            child: Text(
              lesson['name'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: widget.onChanged,
      ),
    );
  }
}