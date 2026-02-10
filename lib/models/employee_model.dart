class Department {
  String? name;
  String? structure;

  Department({this.name, this.structure});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["name"] = name;
    map["structure"] = structure;
    return map;
  }

  Department.fromJson(dynamic json){
    name = json["name"];
    structure = json["structure"];
  }
}

class ItemsEmployee {
  String? fullName;
  num? id;
  Department? department;
  String? staffPosition;

  ItemsEmployee({this.fullName, this.id, this.department, this.staffPosition});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["full_name"] = fullName;
    map["id"] = id;
    if (department != null) {
      map["department"] = department?.toJson();
    }
    map["staff_position"] = staffPosition;
    return map;
  }

  ItemsEmployee.fromJson(dynamic json){
    fullName = json["full_name"];
    id = json["id"];
    department =
    json["department"] != null ? Department.fromJson(json["department"]) : null;
    staffPosition = json["staff_position"];
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

class EmployeeModel {
  List<ItemsEmployee>? itemsList;
  Pagination? pagination;

  EmployeeModel({this.itemsList, this.pagination});

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

  EmployeeModel.fromJson(dynamic json){
    if (json["items"] != null) {
      itemsList = [];
      json["items"].forEach((v) {
        itemsList?.add(ItemsEmployee.fromJson(v));
      });
    }
    pagination =
    json["pagination"] != null ? Pagination.fromJson(json["pagination"]) : null;
  }
}