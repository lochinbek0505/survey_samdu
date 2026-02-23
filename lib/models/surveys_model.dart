class SurveyData {
  num? id;
  String? title;
  String? description;
  num? owner;
  SurveyData({this.id, this.title, this.description, this.owner});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["title"] = title;

    map["description"] = description;
    map['owner'] = owner;
    return map;
  }

  SurveyData.fromJson(dynamic json){
    id = json["id"];
    title = json["title"];
    owner = json["owner"];
    description = json["description"];
  }
}

class SurveysModel {
  List<SurveyData>? dataListList;

  SurveysModel({this.dataListList});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (dataListList != null) {
      map["dataList"] = dataListList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  SurveysModel.fromJson(dynamic json){
    if (json != null) {
      dataListList = [];
      json.forEach((v) {
        dataListList?.add(SurveyData.fromJson(v));
      });
    }
  }
}