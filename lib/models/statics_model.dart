class StaticsModel {
  num? surveyId;
  String? surveyTitle;
  num? totalResponses;
  List<Questions>? questionsList;

  StaticsModel({this.surveyId, this.surveyTitle, this.totalResponses, this.questionsList});

  StaticsModel.fromJson(dynamic json) {
    surveyId = json['survey_id'];
    surveyTitle = json['survey_title'];
    totalResponses = json['total_responses'];
    if (json['questions'] != null) {
      questionsList = [];
      json['questions'].forEach((v) {
        questionsList?.add(Questions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['survey_id'] = surveyId;
    map['survey_title'] = surveyTitle;
    map['total_responses'] = totalResponses;
    if (questionsList != null) {
      map['questions'] = questionsList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Questions {
  num? questionId;
  String? questionText;
  String? questionType;
  List<Results>? resultsList;

  Questions({this.questionId, this.questionText, this.questionType, this.resultsList});

  Questions.fromJson(dynamic json) {
    questionId = json['question_id'];
    questionText = json['question_text'];
    questionType = json['question_type'];
    if (json['results'] != null) {
      resultsList = [];
      json['results'].forEach((v) {
        resultsList?.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['question_id'] = questionId;
    map['question_text'] = questionText;
    map['question_type'] = questionType;
    if (resultsList != null) {
      map['results'] = resultsList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Results {
  num? optionId;
  String? optionText;
  String? eduType;
  num? count;
  String? text; // "text" turidagi savollar uchun
  List<EduItems>? eduItems;

  Results({this.optionId, this.optionText, this.eduType, this.count, this.text, this.eduItems});

  Results.fromJson(dynamic json) {
    optionId = json['option_id'];
    optionText = json['option_text'];
    eduType = json['edu_type'];
    count = json['count'];
    text = json['text'];
    if (json['edu_items'] != null) {
      eduItems = [];
      json['edu_items'].forEach((v) {
        eduItems?.add(EduItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['option_id'] = optionId;
    map['option_text'] = optionText;
    map['edu_type'] = eduType;
    map['count'] = count;
    map['text'] = text;
    if (eduItems != null) {
      map['edu_items'] = eduItems?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class EduItems {
  String? eduId;
  String? eduText;
  num? count;

  EduItems({this.eduId, this.eduText, this.count});

  EduItems.fromJson(dynamic json) {
    eduId = json['edu_id'];
    eduText = json['edu_text'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['edu_id'] = eduId;
    map['edu_text'] = eduText;
    map['count'] = count;
    return map;
  }
}