import 'question_model.dart';

class OptionModel {
  final int id;
  final String text;
  final int order;
  final int question;
  final String eduType;

  final List<QuestionModel> childQuestions;

  OptionModel({
    required this.id,
    required this.text,
    required this.order,
    required this.question,
    required this.eduType,
    required this.childQuestions,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      order: json['order'] ?? 0,
      question: json['question'] ?? 0,
      eduType: json['edu_type'] ?? '',
      childQuestions: QuestionModel.listFromJson(
        json['child_questions'],
      ),
    );
  }

  static List<OptionModel> listFromJson(List<dynamic>? data) {
    if (data == null) return [];
    return data
        .map((e) => OptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "text": text,
    "order": order,
    "question": question,
    "edu_type": eduType,
    "child_questions":
    childQuestions.map((e) => e.toJson()).toList(),
  };
}
