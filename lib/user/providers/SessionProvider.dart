import 'package:flutter/material.dart';
import 'package:survey_samdu/models/employee_model.dart';
import 'package:survey_samdu/models/session_model.dart';
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

  SurveyModel? _survey ;
  SurveyModel? get survey => _survey;

  final ApiService _apiService = ApiService();
  Future<void> getSurvey(dynamic code) async {
    _loading = true;
    notifyListeners();

    try {
      var result = await _apiService.getSurvey(code);

      _survey = result; // null bo‘lishi mumkin
    } catch (e) {
      print("Survey olishda xatolik: $e");
      _survey = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }


  Future<void> getSession(dynamic code) async {
    _loading = true;
    notifyListeners();

    try {
      var result = await _apiService.getSession(code);

      if (result != null) {
        _session = result;
        // isActive null bo'lsa false deb hisoblaymiz
        _isSessionExpired = !(_session.isActive ?? false);
      } else {
        _session = SessionModel();
        _isSessionExpired = true;
      }
    } catch (e) {
      print("Session olishda xatolik: $e");
      _isSessionExpired = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

// SurveyProvider ichidagi getKafedra metodini tekshiring:

  Future<DepartamentModel?> getKafedra(dynamic id) async {
    _loading = true;
    notifyListeners();

    try {
      print('Kafedra yuklash: parent=$id'); // Debug

      var result = await _apiService.getDepartament("?parent=$id");

      print('Kafedra natija: ${result?.items?.length ?? 0}'); // Debug

      if (result != null && result.items != null) {
        print('Kafedralar:');
        for (var item in result.items!) {
          print('  - ${item.name} (ID: ${item.id})');
        }
      }

      return result;
    } catch (e) {
      print("Kafedra olishda xatolik: $e");
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  Future<EmployeeModel?> getEmployee(departamentId,link)async{
    _loading = true;
    notifyListeners();

    try {
      var result = await _apiService.getEmployee(departamentId,link);
      return result;
    }catch (e) {
      print("Employee olishda xatolik: $e");
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> submit(data,code){
    var res=_apiService.submitSurvey(data,code);
    return res;
  }
}