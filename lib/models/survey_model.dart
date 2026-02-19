import 'question_model.dart';

class SurveyModel {
  final int id;
  final String title;
  final String description;
  final int owner;
  final DateTime? createdAt;

  final List<QuestionModel> questions;

  SurveyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.owner,
    required this.createdAt,
    required this.questions,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      owner: json['owner'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      questions: QuestionModel.listFromJson(json['questions']),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "owner": owner,
    "created_at": createdAt?.toIso8601String(),
    "questions": questions.map((e) => e.toJson()).toList(),
  };

  static List<SurveyModel> listFromJson(List<dynamic>? data) {
    if (data == null) return [];
    return data
        .map((e) => SurveyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  SurveyModel copyWith({
    int? id,
    String? title,
    String? description,
    int? owner,
    DateTime? createdAt,
    List<QuestionModel>? questions,
  }) {
    return SurveyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      questions: questions ?? this.questions,
    );
  }
}
