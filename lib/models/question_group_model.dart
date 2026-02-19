class QuestionGroupModel {
  final int id;
  final String name;
  final int order;

  QuestionGroupModel({
    required this.id,
    required this.name,
    required this.order,
  });

  factory QuestionGroupModel.fromJson(Map<String, dynamic> json) {
    return QuestionGroupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  static List<QuestionGroupModel> listFromJson(List<dynamic>? data) {
    if (data == null) return [];
    return data
        .map((e) =>
        QuestionGroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "order": order,
  };

  QuestionGroupModel copyWith({
    int? id,
    String? name,
    int? order,
  }) {
    return QuestionGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }
}
