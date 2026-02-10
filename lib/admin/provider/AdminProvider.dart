import 'package:flutter/material.dart';
import 'package:survey_samdu/models/groups_model.dart';
import 'package:survey_samdu/models/session_list_model.dart';
import 'package:survey_samdu/models/session_model.dart';
import 'package:survey_samdu/models/statics_model.dart';
import 'package:survey_samdu/models/surveys_model.dart';
import 'package:survey_samdu/service/ApiService.dart';
import '../service/CacheService.dart';


class AdminProvider with ChangeNotifier {

  bool _loading = false;

  bool get loading => _loading;

  ApiService _apiService = ApiService();

  CacheService _cacheService = CacheService();

  SurveysModel _surveysModel = SurveysModel();

  SurveysModel get surveysModel => _surveysModel;


  SessionListModel sessionListModel = SessionListModel();

  SessionListModel get sessions => sessionListModel;

  bool _checkLogin = false;

  bool get checkLogin => _checkLogin;

  Future<void> getSessions(context) async {
    _loading = true;
    notifyListeners();

    var result = await _apiService.getSessions(
      _cacheService.readLoginResponse()!.access!,context
    );
    sessionListModel = result!;

    _loading = false;
    notifyListeners();
  }

  Future<SessionModel> createSession(data) async {
    _loading = true;
    notifyListeners();

    var result = await _apiService.createSession(
      data,
      _cacheService.readLoginResponse()!.access!,
    );

    _loading = false;
    notifyListeners();

    return result;
  }

  Future<SessionModel> updateSession(data, id) async {
    _loading = true;
    notifyListeners();

    var result = await _apiService.updateSession(
      id,
      data,
      _cacheService.readLoginResponse()!.access!,
    );

    _loading = false;
    notifyListeners();

    return result;
  }

  Future<void> deleteSession(id) async {
    _loading = true;
    notifyListeners();

    var result = await _apiService.deleteSession(
      id,
      _cacheService.readLoginResponse()!.access!,
    );

    _loading = false;
    notifyListeners();
  }

   checkLoginStatus() {
     if(_cacheService.readLoginResponse() != null){
       _checkLogin = true;
     }else{
       _checkLogin = false;
     }
  }

  Future<void> login(
    String username,
    String password,
    BuildContext context,
  ) async {
    _loading = true;
    notifyListeners();

    final response = await _apiService.login({
      'username': username,
      'password': password,
    });

    if (response.access != null) {
      _cacheService.saveLoginResponse(response);
      _checkLogin = true;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tizimga muofaqqiyatli kirdingiz')),
      );
    }
    _loading = false;
    notifyListeners();
  }

  Future<GroupsModel?> getGroups(departament_id) async {
    var result = await _apiService.getGroups(departament_id);
    return result;
  }

  Future<StaticsModel?> getStatics(departament_id, link,context) async {
    var result = await _apiService.getStatics(
      departament_id,
      link,
      _cacheService.readLoginResponse()!.access!,
      context
    );
    return result;
  }

  Future<void> getSurveys() async {
    _loading = true;
    notifyListeners();
    var result = await _apiService.getSurveys(

      _cacheService.readLoginResponse()!.access!,
    );


    _loading = false;
    notifyListeners();
    _surveysModel = result!;

  }
}
