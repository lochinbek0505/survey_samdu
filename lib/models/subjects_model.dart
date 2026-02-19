class Items {
  num? id;
  String? code;
  String? name;
  String? subjectGroup;
  String? educationType;

  Items({this.id, this.code, this.name, this.subjectGroup, this.educationType});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["code"] = code;
    map["name"] = name;
    map["subject_group"] = subjectGroup;
    map["education_type"] = educationType;
    return map;
  }

  Items.fromJson(dynamic json){
    id = json["id"];
    code = json["code"];
    name = json["name"];
    subjectGroup = json["subject_group"];
    educationType = json["education_type"];
  }
}

class Pagination {
  num? totalCount;
  num? pageSize;
  num? pageCount;
  num? page;

  Pagination({this.totalCount, this.pageSize, this.pageCount, this.page});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["totalCount"] = totalCount;
    map["pageSize"] = pageSize;
    map["pageCount"] = pageCount;
    map["page"] = page;
    return map;
  }

  Pagination.fromJson(dynamic json){
    totalCount = json["totalCount"];
    pageSize = json["pageSize"];
    pageCount = json["pageCount"];
    page = json["page"];
  }
}

class SubjectsModel {
  List<Items>? itemsList;
  Pagination? pagination;

  SubjectsModel({this.itemsList, this.pagination});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (itemsList != null) {
      map["items"] = itemsList?.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      map["pagination"] = pagination?.toJson();
    }
    return map;
  }

  SubjectsModel.fromJson(dynamic json){
    if (json["items"] != null) {
      itemsList = [];
      json["items"].forEach((v) {
        itemsList?.add(Items.fromJson(v));
      });
    }
    pagination =
    json["pagination"] != null ? Pagination.fromJson(json["pagination"]) : null;
  }
}