import 'package:flutter/cupertino.dart';
import 'package:survey_samdu/admin/service/CacheService.dart';
import 'package:survey_samdu/models/question_group_model.dart';
import 'package:survey_samdu/models/surveys_model.dart';
import 'package:survey_samdu/service/ApiService.dart';

class GroupsProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get loading => _isLoading;

  var _apiService = ApiService();
  var _cache = CacheService();

  List<QuestionGroupModel> _surveysModel = List.empty();

  List<QuestionGroupModel> get surveysModel => _surveysModel;

  Future<void> getSurveysGroup() async {
    _isLoading = true;
    notifyListeners();
    var token = _cache.readLoginResponse();
    var response = await _apiService.getSurveysGroup(token!.access);
    _surveysModel = response!;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createSurveyGroup(QuestionGroupModel data) async {
    var json = data.toJson();
    _isLoading = true;
    notifyListeners();
    var token = _cache.readLoginResponse();
    var response = await _apiService.createSurveyGroup(json, token!.access);
    await getSurveysGroup();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSurveyGroup(QuestionGroupModel data) async {
    var json = data.toJson();
    _isLoading = true;
    notifyListeners();
    var token = _cache.readLoginResponse();
    var response = await _apiService.updateSurveyGroup(
      json,
      token!.access,
      data.id,
    );
    await getSurveysGroup();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteSurveyGroup(QuestionGroupModel data) async {
    _isLoading = true;
    notifyListeners();
    var token = _cache.readLoginResponse();
    var response = await _apiService.deleteSurveyGroup(token!.access, data.id);
    await getSurveysGroup();
    _isLoading = false;
    notifyListeners();
  }
}