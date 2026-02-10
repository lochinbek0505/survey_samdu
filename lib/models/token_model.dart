class TokenModel {
  String? refresh;
  String? access;

  TokenModel({this.refresh, this.access});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["refresh"] = refresh;
    map["access"] = access;
    return map;
  }

  TokenModel.fromJson(dynamic json){
    refresh = json["refresh"];
    access = json["access"];
  }
}