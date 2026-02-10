class ItemsDepartament {
  final num? id;
  final String? name;
  final String? structure;
  final String? structureId;

  ItemsDepartament({this.id, this.name, this.structure, this.structureId});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "structure": structure,
      "structure_id": structureId,
    };
  }

  factory ItemsDepartament.fromJson(Map<String, dynamic> json) {
    return ItemsDepartament(
      id: json["id"],
      name: json["name"],
      structure: json["structure"],
      structureId: json["structure_id"]?.toString(),
    );
  }
}

class DepartamentModel {
  final List<ItemsDepartament>? items;
  final Pagination? pagination;

  DepartamentModel({this.items, this.pagination});

  factory DepartamentModel.fromJson(Map<String, dynamic> json) {
    return DepartamentModel(
      items: json["items"] != null
          ? List<ItemsDepartament>.from(json["items"].map((x) => ItemsDepartament.fromJson(x)))
          : null,
      pagination: json["pagination"] != null
          ? Pagination.fromJson(json["pagination"])
          : null,
    );
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

  Pagination.fromJson(dynamic json) {
    totalCount = json["totalCount"];
    pageSize = json["pageSize"];
    pageCount = json["pageCount"];
    page = json["page"];
  }
}

