import 'package:flutter/material.dart';
import 'package:survey_samdu/models/employee_model.dart';
import 'package:survey_samdu/models/session_model.dart';
import 'package:survey_samdu/models/subjects_model.dart';
import 'package:survey_samdu/models/survey_model.dart';
import 'package:survey_samdu/service/ApiService.dart';

import '../../models/departament_model.dart';

class SurveyProvider with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  SessionModel _session = SessionModel();
  SessionModel get session => _session;

  bool _isSessionExpired = false;
  bool get isSessionExpired => _isSessionExpired;

  SurveyModel? _survey;
  SurveyModel? get survey => _survey;

  String? _errorMessage; // ✅ Xatolik xabarini saqlash
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  // ✅ Dispose holatini kuzatish
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ✅ Xavfsiz notifyListeners
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> getSurvey(dynamic code) async {
    if (_loading) return; // ✅ Agar allaqachon yuklash jarayonida bo'lsa, qayta chaqirmaslik

    _loading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      var result = await _apiService.getSurvey(code);
      _survey = result;
    } catch (e) {
      print("Survey olishda xatolik: $e");
      _errorMessage = "So'rovnomani yuklashda xatolik: $e";
      _survey = null;
    } finally {
      _loading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> getSession(dynamic code) async {
    if (_loading) return; // ✅ Takroriy chaqiruvlarni oldini olish

    _loading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      var result = await _apiService.getSession(code);

      if (result != null) {
        _session = result;
        _isSessionExpired = !(_session.isActive ?? false);
      } else {
        _session = SessionModel();
        _isSessionExpired = true;
      }
    } catch (e) {
      print("Session olishda xatolik: $e");
      _errorMessage = "Sessiyani yuklashda xatolik: $e";
      _isSessionExpired = true;
    } finally {
      _loading = false;
      _safeNotifyListeners();
    }
  }

  Future<DepartamentModel?> getKafedra(dynamic id) async {
    if (_loading) return null; // ✅ Takroriy chaqiruvlarni oldini olish

    _loading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      print('Kafedra yuklash: parent=$id');
      var result = await _apiService.getDepartament("?parent=$id");

      print('Kafedra natija: ${result?.items?.length ?? 0}');

      if (result != null && result.items != null) {
        print('Kafedralar:');
        for (var item in result.items!) {
          print('  - ${item.name} (ID: ${item.id})');
        }
      }

      return result;
    } catch (e) {
      print("Kafedra olishda xatolik: $e");
      _errorMessage = "Kafedrani yuklashda xatolik: $e";
      return null;
    } finally {
      _loading = false;
      _safeNotifyListeners();
    }
  }

  Future<EmployeeModel?> getEmployee(departamentId, link) async {
    if (_loading) return null; // ✅ Takroriy chaqiruvlarni oldini olish

    _loading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      var result = await _apiService.getEmployee(departamentId, link);
      return result;
    } catch (e) {
      print("Employee olishda xatolik: $e");
      _errorMessage = "Xodimlarni yuklashda xatolik: $e";
      return null;
    } finally {
      _loading = false;
      _safeNotifyListeners();
    }
  }

  Future<SubjectsModel?> getSubjects([link]) async {
    if (_loading) return null; // ✅ Takroriy chaqiruvlarni oldini olish

    _loading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      var result = await _apiService.getSubjects(link);
      return result;
    } catch (e) {
      print("Subjects olishda xatolik: $e");
      _errorMessage = "Fanlarni yuklashda xatolik: $e";
      return null;
    } finally {
      _loading = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> submit(data, code) async {
    if (_loading) return false; // ✅ Takroriy yuborishni oldini olish

    _loading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      var res = await _apiService.submitSurvey(data, code);
      return res;
    } catch (e) {
      print("Submit xatolik: $e");
      _errorMessage = "Ma'lumotlarni yuborishda xatolik: $e";
      return false;
    } finally {
      _loading = false;
      _safeNotifyListeners();
    }
  }

  // ✅ Xatolikni tozalash
  void clearError() {
    _errorMessage = null;
    _safeNotifyListeners();
  }
}