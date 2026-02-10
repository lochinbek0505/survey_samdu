class DataList {
  num? id;
  num? survey;
  String? name;
  String? groupName;
  String? code;
  String? startTime;
  num? duration;
  bool? isActive;
  int? responseCount;


  DataList(
      {this.id, this.survey, this.name, this.groupName, this.code, this.startTime, this.duration, this.isActive,this.responseCount});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["survey"] = survey;
    map["name"] = name;
    map["group_name"] = groupName;
    map["code"] = code;
    map["start_time"] = startTime;
    map["duration"] = duration;
    map["response_count"]=responseCount;
    map["is_active"] = isActive;
    return map;
  }

  DataList.fromJson(dynamic json){
    id = json["id"];
    survey = json["survey"];
    name = json["name"];
    groupName = json["group_name"];
    code = json["code"];
    startTime = json["start_time"];
    duration = json["duration"];
    responseCount = json["response_count"];
    isActive = json["is_active"];
  }
}

class SessionListModel {
  List<DataList>? dataListList;

  SessionListModel({this.dataListList});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (dataListList != null) {
      map["dataList"] = dataListList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  SessionListModel.fromJson(dynamic json){
    if (json != null) {
      dataListList = [];
      json.forEach((v) {
        dataListList?.add(DataList.fromJson(v));
      });
    }
  }
}