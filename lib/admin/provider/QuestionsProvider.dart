import 'package:flutter/material.dart';
import 'package:survey_samdu/admin/service/CacheService.dart';
import 'package:survey_samdu/models/question_group_model.dart';
import 'package:survey_samdu/models/question_model.dart';
import 'package:survey_samdu/service/ApiService.dart';

class QuestionsProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<QuestionModel> _questions = [];

  List<QuestionModel> get questions => _questions;

  List<QuestionGroupModel> _questionGroups = [];

  List<QuestionGroupModel> get questionGroups => _questionGroups;

  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  // Helper method to get token
  Future<String?> _getToken() async {
    return _cacheService.readLoginResponse()?.access;
  }

  // Helper method to show snackbar safely
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getQuestions(int id) async {
    _setLoading(true);

    try {
      final token = await _getToken();
      if (token == null) {
        _setLoading(false);
        return;
      }

      final response = await _apiService.getQuestions(token, id);
      if (response != null) {
        _questions = response;
      }
    } catch (e) {
      debugPrint('Error fetching questions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getQuestionGroups() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await _apiService.getSurveysGroup(token);
      if (response != null) {
        _questionGroups = response;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching question groups: $e');
    }
  }

  Future<bool> addQuestion(
    Map<String, dynamic> data,
    BuildContext context,
    int surveyId,
  ) async {
    _setLoading(true);

    try {
      final token = await _getToken();
      if (token == null) {
        _setLoading(false);
        return false;
      }

      final response = await _apiService.addQustion(token, data);

      if (response) {
        await getQuestions(surveyId);
        if (context.mounted) {
          _showSnackBar(context, "Savol muvaffaqiyatli qo'shildi");
        }
        return true;
      } else {
        if (context.mounted) {
          _showSnackBar(context, "Savol qo'shishda xatolik", isError: true);
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error adding question: $e');
      if (context.mounted) {
        _showSnackBar(context, "Savol qo'shishda xatolik", isError: true);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateQuestion(
    Map<String, dynamic> data,
    BuildContext context,
    int surveyId,
    int questionId,
  ) async {
    _setLoading(true);

    try {
      final token = await _getToken();
      if (token == null) {
        _setLoading(false);
        return false;
      }

      final response = await _apiService.updateQustion(token, data, questionId);

      if (response) {
        await getQuestions(surveyId);
        if (context.mounted) {
          _showSnackBar(context, "Savol muvaffaqiyatli yangilandi");
        }
        return true;
      } else {
        if (context.mounted) {
          _showSnackBar(context, "Savol tahrirlashda xatolik", isError: true);
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error updating question: $e');
      if (context.mounted) {
        _showSnackBar(context, "Savol tahrirlashda xatolik", isError: true);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteQuestion(
    BuildContext context,
    int questionId,
    int surveyId,
  ) async {
    _setLoading(true);

    try {
      final token = await _getToken();
      if (token == null) {
        _setLoading(false);
        return false;
      }

      final response = await _apiService.deleteQueston(token, questionId);

      if (response) {
        await getQuestions(surveyId);
        if (context.mounted) {
          _showSnackBar(context, "Savol muvaffaqiyatli o'chirildi");
        }
        return true;
      } else {
        if (context.mounted) {
          _showSnackBar(context, "Savol o'chirishda xatolik", isError: true);
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting question: $e');
      if (context.mounted) {
        _showSnackBar(context, "Savol o'chirishda xatolik", isError: true);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
