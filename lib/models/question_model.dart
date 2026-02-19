import 'option_model.dart';

class QuestionModel {
  final int id;
  final int survey;
  final String text;
  final String questionType;
  final bool isRequired;
  final int order;
  final int group;
  final int? parentOption;

  final List<OptionModel> options;

  QuestionModel({
    required this.id,
    required this.survey,
    required this.text,
    required this.questionType,
    required this.isRequired,
    required this.order,
    required this.group,
    required this.parentOption,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? 0,
      survey: json['survey'] ?? 0,
      text: json['text'] ?? '',
      questionType: json['question_type'] ?? '',
      isRequired: json['is_required'] ?? false,
      order: json['order'] ?? 0,
      group: json['group'] ?? 0,
      parentOption: json['parent_option'],
      options: OptionModel.listFromJson(json['options']),
    );
  }

  static List<QuestionModel> listFromJson(List<dynamic>? data) {
    if (data == null) return [];
    return data
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "survey": survey,
    "text": text,
    "question_type": questionType,
    "is_required": isRequired,
    "order": order,
    "group": group,
    "parent_option": parentOption,
    "options": options.map((e) => e.toJson()).toList(),
  };
}
