

class TokenModel {
  String? refresh;
  String? access;
  UserModel? user;

  TokenModel({this.refresh, this.access, this.user});

  TokenModel.fromJson(Map<String, dynamic> json) {
    refresh = json["refresh"];
    access = json["access"];
    user = json["user"] != null ? UserModel.fromJson(json["user"]) : null;
  }

  Map<String, dynamic> toJson() {
    return {"refresh": refresh, "access": access, "user": user?.toJson()};
  }
}

class UserModel {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? fullName;
  String? departmentName;
  String? role;
  bool? isSuperuser;

  UserModel({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.departmentName,
    this.role,
    this.isSuperuser,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    username = json["username"];
    firstName = json["first_name"];
    lastName = json["last_name"];
    fullName = json["full_name"];
    departmentName = json["department_name"];
    role = json["role"];
    isSuperuser = json["is_superuser"];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "first_name": firstName,
      "last_name": lastName,
      "full_name": fullName,
      "department_name": departmentName,
      "role": role,
      "is_superuser": isSuperuser,
    };
  }
}
