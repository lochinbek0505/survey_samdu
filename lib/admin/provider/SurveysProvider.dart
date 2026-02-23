import 'package:flutter/cupertino.dart';
import 'package:survey_samdu/admin/service/CacheService.dart';
import 'package:survey_samdu/models/surveys_model.dart';
import 'package:survey_samdu/models/users_model.dart';
import 'package:survey_samdu/service/ApiService.dart';

class SurveysProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  var _apiService = ApiService();
  var _cache = CacheService();

  UsersModel _usersModel = UsersModel();

  UsersModel get usersModel => _usersModel;

  SurveysModel _surveysModel = SurveysModel();

  SurveysModel get surveysModel => _surveysModel;

  Future<void> getSurveys() async {
    _isLoading = true;
    notifyListeners();
    var token = _cache.readLoginResponse();
    var response = await _apiService.getSurveys(token!.access);
    _surveysModel = response!;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getUsers() async {
    _isLoading = true;
    notifyListeners();
    var token = _cache.readLoginResponse();
    var response = await _apiService.getUsers(token!.access);
    await getSurveys();
    _usersModel = response!;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createSurvey(SurveyData data) async {
    var json = data.toJson();
    _isLoading = true;
    notifyListeners();
    var token = _cache.readLoginResponse();
    var response = await _apiService.createSurvey(json, token!.access);
    await getSurveys();
    // _surveysModel.dataListList!.add(response);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSurvey(SurveyData data) async {
    var json = data.toJson();
    _isLoading = true;
    notifyListeners();
    var token = _cache.readLoginResponse();
    var response = await _apiService.updateSurvey(json, token!.access, data.id);
    await getSurveys();
    // _surveysModel.dataListList!.add(response);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteSurvey(SurveyData data) async {
    var json = data.toJson();
    _isLoading = true;
    notifyListeners();
    var token = _cache.readLoginResponse();
    var response = await _apiService.deleteSurvey(token!.access, data.id);
    await getSurveys();
    // if (response) {
    //   _surveysModel.dataListList!.removeWhere((e) => e.id == data.id);
    // }
    _isLoading = false;
    notifyListeners();
  }
}
