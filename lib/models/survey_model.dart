import 'package:survey_samdu/models/question_model.dart';

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
    this.createdAt,
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
      questions: json['questions'] != null
          ? (json['questions'] as List)
          .map((e) => QuestionModel.fromJson(e))
          .toList()
          : [],
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
