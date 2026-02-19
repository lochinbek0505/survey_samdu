class DataList {
  num? id;
  String? username;
  String? fullName;
  String? departmentName;
  String? role;
  bool? isSuperuser;

  DataList(
      {this.id, this.username, this.fullName, this.departmentName, this.role, this.isSuperuser});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["id"] = id;
    map["username"] = username;
    map["full_name"] = fullName;
    map["department_name"] = departmentName;
    map["role"] = role;
    map["is_superuser"] = isSuperuser;
    return map;
  }

  DataList.fromJson(dynamic json){
    id = json["id"];
    username = json["username"];
    fullName = json["full_name"];
    departmentName = json["department_name"];
    role = json["role"];
    isSuperuser = json["is_superuser"];
  }
}

class UsersModel {
  List<DataList>? dataListList;

  UsersModel({this.dataListList});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (dataListList != null) {
      map["dataList"] = dataListList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  UsersModel.fromJson(dynamic json){
    if (json != null) {
      dataListList = [];
      json.forEach((v) {
        dataListList?.add(DataList.fromJson(v));
      });
    }
  }
}