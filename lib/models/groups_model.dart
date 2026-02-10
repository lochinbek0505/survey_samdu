class Department {
  num? id;
  String? name;

  Department({this.id, this.name});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    return map;
  }

  Department.fromJson(dynamic json){
    id = json["id"];
    name = json["name"];
  }
}

class Specialty {
  String? code;
  String? name;

  Specialty({this.code, this.name});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["code"] = code;
    map["name"] = name;
    return map;
  }

  Specialty.fromJson(dynamic json){
    code = json["code"];
    name = json["name"];
  }
}

class Items {
  num? id;
  String? name;
  Department? department;
  Specialty? specialty;
  String? educationLanguage;

  Items(
      {this.id, this.name, this.department, this.specialty, this.educationLanguage});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    if (department != null) {
      map["department"] = department?.toJson();
    }
    if (specialty != null) {
      map["specialty"] = specialty?.toJson();
    }
    map["education_language"] = educationLanguage;
    return map;
  }

  Items.fromJson(dynamic json){
    id = json["id"];
    name = json["name"];
    department =
    json["department"] != null ? Department.fromJson(json["department"]) : null;
    specialty =
    json["specialty"] != null ? Specialty.fromJson(json["specialty"]) : null;
    educationLanguage = json["education_language"];
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

class GroupsModel {
  List<Items>? itemsList;
  Pagination? pagination;

  GroupsModel({this.itemsList, this.pagination});

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

  GroupsModel.fromJson(dynamic json){
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