import 'dart:convert';
import 'dart:html';

import 'package:survey_samdu/models/token_model.dart';


class CacheService {
  void saveToCache(String key, String value) {
    window.localStorage[key] = value;
  }

  String? readFromCache(String key) {
    return window.localStorage[key];
  }

  void clearAllCache() {
    window.localStorage.clear();
  }

  // 🔹 Modelni cachega yozish
  void saveLoginResponse(TokenModel response) {
    final jsonString = jsonEncode(response.toJson());
    saveToCache("login_response", jsonString);
  }

  // 🔹 Modelni cachedan o‘qish
  TokenModel? readLoginResponse() {
    final jsonString = readFromCache("login_response");
    if (jsonString == null) return null;
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return TokenModel.fromJson(json);
  }
}