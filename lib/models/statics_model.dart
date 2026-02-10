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
  num? count;
  String? text; // JSON dagi "text" maydoni uchun
  List<Teachers>? teachersList;
  List<Departments>? departmentsList; // Dynamic o'rniga maxsus class

  Results({this.optionId, this.optionText, this.count, this.text, this.teachersList, this.departmentsList});

  Results.fromJson(dynamic json) {
    optionId = json['option_id'];
    optionText = json['option_text'];
    count = json['count'];
    text = json['text'];
    if (json['teachers'] != null) {
      teachersList = [];
      json['teachers'].forEach((v) {
        teachersList?.add(Teachers.fromJson(v));
      });
    }
    if (json['departments'] != null) {
      departmentsList = [];
      json['departments'].forEach((v) {
        departmentsList?.add(Departments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['option_id'] = optionId;
    map['option_text'] = optionText;
    map['count'] = count;
    map['text'] = text;
    if (teachersList != null) {
      map['teachers'] = teachersList?.map((v) => v.toJson()).toList();
    }
    if (departmentsList != null) {
      map['departments'] = departmentsList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Teachers {
  String? teacherId;
  String? teacherName;
  num? count;

  Teachers({this.teacherId, this.teacherName, this.count});

  Teachers.fromJson(dynamic json) {
    teacherId = json['teacher_id'];
    teacherName = json['teacher_name'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['teacher_id'] = teacherId;
    map['teacher_name'] = teacherName;
    map['count'] = count;
    return map;
  }
}

class Departments {
  String? departmentId;
  String? departmentName;
  num? count;

  Departments({this.departmentId, this.departmentName, this.count});

  Departments.fromJson(dynamic json) {
    // JSON dagi noodatiy key'larga moslash
    departmentId = json['department_id'];
    departmentName = json['department_name'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['department_id'] = departmentId;
    map['department_name'] = departmentName;
    map['count'] = count;
    return map;
  }
}