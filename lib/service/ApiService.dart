import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:survey_samdu/models/departament_model.dart';
import 'package:survey_samdu/models/employee_model.dart';
import 'package:survey_samdu/models/groups_model.dart';
import 'package:survey_samdu/models/question_group_model.dart';
import 'package:survey_samdu/models/question_model.dart';
import 'package:survey_samdu/models/session_list_model.dart';
import 'package:survey_samdu/models/session_model.dart';
import 'package:survey_samdu/models/subjects_model.dart';
import 'package:survey_samdu/models/survey_model.dart';
import 'package:survey_samdu/models/token_model.dart';
import 'package:survey_samdu/models/users_model.dart';

import '../admin/page/LoginPage.dart';
import '../admin/service/CacheService.dart';
import '../models/statics_model.dart';
import '../models/surveys_model.dart';

class ApiService {
  static String baseUrl = "https://apisurvey.samdu.uz/api/";

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 45),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<SessionModel?> getSession(code) async {
    try {
      final response = await _dio.get(
        "sessions/$code/",
        options: Options(headers: {'Accept': 'application/json'}),
      );

      return SessionModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }

      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<SurveysModel?> getSurveys(token) async {
    print("getSurveys");

    print("${baseUrl}surveys/");
    try {
      final response = await _dio.get(
        "surveys/",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      print(response);
      return SurveysModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }

      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<SurveyModel?> getSurvey(code) async {
    print("${baseUrl}surveys/session/$code/");
    try {
      final response = await _dio.get(
        "surveys/session/$code/",
        options: Options(headers: {'Accept': 'application/json'}),
      );
      print(response);
      return SurveyModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }

      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<GroupsModel?> getGroups(id) async {
    try {
      final response = await _dio.get(
        "groups/?department=$id&limit=200",
        options: Options(headers: {'Accept': 'application/json'}),
      );
      print(response);
      return GroupsModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }

      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<StaticsModel?> getStatics(id, link, token, context) async {
    try {
      // surveys/1/results/
      print("surveys/$id/results/$link");
      final response = await _dio.get(
        "surveys/$id/results/$link",
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print(response);
      return StaticsModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout(context);
        return null;
      }

      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<DepartamentModel?> getDepartament(link) async {
    try {
      // Agar link null bo'lib kelsa ham xato berishi mumkin
      if (link == null) return null;
      print("${baseUrl}departments/$link&limit=200");
      final response = await _dio.get(
        "departments/$link&limit=200",
        // link oxirida '/' yetishmayotgan bo'lishi mumkin
        options: Options(headers: {'Accept': 'application/json'}),
      );
      print(response);
      // Agar response.data null bo'lsa, xato beradi
      if (response.data == null) return null;

      return DepartamentModel.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      return null;
    } catch (e) {
      print('General Error: $e');
      return null;
    }
  }

  Future<EmployeeModel?> getEmployee(deparament_id, link) async {
    try {
      print("${baseUrl}employees/$link");
      final response = await _dio.get(
        "employees/$link",
        options: Options(headers: {'Accept': 'application/json'}),
      );
      print(response);
      return EmployeeModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        return null;
      }

      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool> submitSurvey(data, code) async {
    final response = await _dio.post(
      "responses/submit/$code/",
      data: data,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    return response.statusCode == 201;
  }

  Future<TokenModel> login(data) async {
    try {
      final response = await _dio.post(
        "login/",
        data: data,
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return TokenModel.fromJson(response.data);
    } catch (e) {
      print(e);
      return TokenModel();
    }
  }

  Future<List<QuestionGroupModel>?> getSurveysGroup(token) async {
    try {
      final response = await _dio.get(
        "question-groups/",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      print(response);
      return QuestionGroupModel.listFromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }

      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
  Future<bool> deleteQueston(token, id) async {
    try {
      final response = await _dio.delete(
        "questions/$id/",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return response.statusCode == 204;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteSurveyGroup(token, id) async {
    try {
      final response = await _dio.delete(
        "question-groups/$id/",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return response.statusCode == 204;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<QuestionGroupModel?> createSurveyGroup(data, token) async {
    try {
      final response = await _dio.post(
        "question-groups/",
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return QuestionGroupModel.fromJson(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<QuestionGroupModel?> updateSurveyGroup(data, token, id) async {
    try {
      final response = await _dio.put(
        "question-groups/$id/",
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return QuestionGroupModel.fromJson(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<SurveyData> updateSurvey(data, token, id) async {
    try {
      final response = await _dio.put(
        "surveys/$id/",
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return SurveyData.fromJson(response.data);
    } catch (e) {
      print(e);
      return SurveyData();
    }
  }

  Future<List<QuestionModel>?> getQuestions(token, id) async {
    try {
      final response = await _dio.get(
        "questions/?survey=$id",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return QuestionModel.listFromJson(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> deleteSurvey(token, id) async {
    try {
      final response = await _dio.delete(
        "surveys/$id/",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return response.statusCode == 204;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<SurveyData> createSurvey(data, token) async {
    try {
      final response = await _dio.post(
        "surveys/",
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return SurveyData.fromJson(response.data);
    } catch (e) {
      print(e);
      return SurveyData();
    }
  }

  Future<SessionModel> createSession(data, token) async {
    try {
      final response = await _dio.post(
        "sessions/",
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return SessionModel.fromJson(response.data);
    } catch (e) {
      print(e);
      return SessionModel();
    }
  }

  Future<SessionListModel?> getSessions(token, context) async {
    try {
      final response = await _dio.get(
        "sessions/",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return SessionListModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        await logout(context);
        return null;
      }

      return null;
    } catch (e) {
      print(e);
      return SessionListModel();
    }
  }

  Future<void> logout(BuildContext context) async {
    CacheService service = CacheService();

    service.clearAllCache();

    // Context hali yaroqli ekanligini tekshirish
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<SessionModel> updateSession(id, data, token) async {
    try {
      final response = await _dio.put(
        "sessions/$id/",
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return SessionModel.fromJson(response.data);
    } catch (e) {
      print(e);
      return SessionModel();
    }
  }

  Future<void> deleteSession(id, token) async {
    try {
      final response = await _dio.delete(
        "sessions/$id/",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<UsersModel?> getUsers(token) async {
    print("${baseUrl}users/");
    try {
      final response = await _dio.get(
        "users/",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      print(response);
      return UsersModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }

      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<SubjectsModel?> getSubjects(link) async {
    print("${baseUrl}subjects/");
    try {
      final response = await _dio.get(
        "subjects/$link",
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      print(response);
      return SubjectsModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }

      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool> addQustion(token, data) async {
    try {
      final response = await _dio.post(
        "questions/",
        data: data,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.statusCode == 201;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateQustion(token, data, num id) async {
    try {
      print(data);
      print("questions/$id/");
      final response = await _dio.put(
        "questions/$id/",
        data: data,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
