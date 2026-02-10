class SessionModel {
  num? id;
  num? survey;
  String? name;
  String? groupName;
  String? code;
  String? startTime;
  num? duration;
  bool? isActive;

  SessionModel(
      {this.id, this.survey, this.name, this.groupName, this.code, this.startTime, this.duration, this.isActive});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["survey"] = survey;
    map["name"] = name;
    map["group_name"] = groupName;
    map["code"] = code;
    map["start_time"] = startTime;
    map["duration"] = duration;
    map["is_active"] = isActive;
    return map;
  }

  SessionModel.fromJson(dynamic json){
    id = json["id"];
    survey = json["survey"];
    name = json["name"];
    groupName = json["group_name"];
    code = json["code"];
    startTime = json["start_time"];
    duration = json["duration"];
    isActive = json["is_active"];
  }
}