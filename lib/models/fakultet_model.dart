class Faculties {
  num? id;
  String? name;
  String? structure;

  Faculties({this.id, this.name, this.structure});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    map["structure"] = structure;
    return map;
  }

  Faculties.fromJson(dynamic json){
    id = json["id"];
    name = json["name"];
    structure = json["structure"];
  }
}

class FakultetModel {
  List<Faculties>? dataListList;

  FakultetModel({this.dataListList});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (dataListList != null) {
      map["dataList"] = dataListList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  FakultetModel.fromJson(dynamic json){
    if (json != null) {
      dataListList = [];
      json.forEach((v) {
        dataListList?.add(Faculties.fromJson(v));
      });
    }
  }
}