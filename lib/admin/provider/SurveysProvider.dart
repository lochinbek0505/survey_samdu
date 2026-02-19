import 'package:flutter/cupertino.dart';
import 'package:survey_samdu/admin/service/CacheService.dart';
import 'package:survey_samdu/models/surveys_model.dart';
import 'package:survey_samdu/service/ApiService.dart';

class SurveysProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  var _apiService = ApiService();
  var _cache = CacheService();

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
}
