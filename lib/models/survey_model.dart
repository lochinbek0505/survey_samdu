class Option {
  num? id;
  String? text;
  num? order;

  Option({this.id, this.text, this.order});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["text"] = text;
    map["order"] = order;
    return map;
  }

  Option.fromJson(dynamic json){
    id = json["id"];
    text = json["text"];
    order = json["order"];
  }
}

class Questions {
  num? id;
  String? text;
  String? questionType;
  bool? isRequired;
  num? order;
  bool? isTeacher;
  bool? isDepartment;
  List<Option>? optionsList;

  Questions(
      {this.id, this.text, this.questionType, this.isRequired, this.order, this.isTeacher, this.isDepartment, this.optionsList});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["text"] = text;
    map["question_type"] = questionType;
    map["is_required"] = isRequired;
    map["order"] = order;
    map["is_teacher"] = isTeacher;
    map["is_department"] = isDepartment;
    if (optionsList != null) {
      map["options"] = optionsList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  Questions.fromJson(dynamic json){
    id = json["id"];
    text = json["text"];
    questionType = json["question_type"];
    isRequired = json["is_required"];
    order = json["order"];
    isTeacher = json["is_teacher"];
    isDepartment = json["is_department"];
    if (json["options"] != null) {
      optionsList = [];
      json["options"].forEach((v) {
        optionsList?.add(Option.fromJson(v));
      });
    }
  }
}

class SurveyModel {
  num? id;
  String? title;
  String? description;
  List<Questions>? questionsList;
  String? createdAt;

  SurveyModel(
      {this.id, this.title, this.description, this.questionsList, this.createdAt});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["title"] = title;
    map["description"] = description;
    if (questionsList != null) {
      map["questions"] = questionsList?.map((v) => v.toJson()).toList();
    }
    map["created_at"] = createdAt;
    return map;
  }

  SurveyModel.fromJson(dynamic json){
    id = json["id"];
    title = json["title"];
    description = json["description"];
    if (json["questions"] != null) {
      questionsList = [];
      json["questions"].forEach((v) {
        questionsList?.add(Questions.fromJson(v));
      });
    }
    createdAt = json["created_at"];
  }
}