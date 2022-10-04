import 'dart:convert';

class User {
  User({
    required this.token,
    required this.id,
    required this.mobile,
    this.firstName,
    this.lastName,
  });
  int id;
  String token;
  String mobile;
  String? firstName;
  String? lastName;

  factory User.fromJson(Map<String, dynamic> json) => User(
        token: json["token"],
        id: json["id"],
        mobile: json["mobile"],
        firstName: json["first_name"],
        lastName: json["last_name"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "id": id,
        "mobile": mobile,
        "first_name": firstName,
        "last_name": lastName,
      };
}

TokenRequest tokenRequestFromJson(String str) =>
    TokenRequest.fromJson(json.decode(str));

String tokenRequestToJson(TokenRequest data) => json.encode(data.toJson());

class TokenRequest {
  TokenRequest({
    required this.success,
    this.uuid,
    this.error,
  });

  bool success;
  String? uuid;
  String? error;

  factory TokenRequest.fromJson(Map<String, dynamic> json) => TokenRequest(
        success: json["success"],
        uuid: json["uuid"],
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "uuid": uuid,
        "error": error,
      };
}

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  LoginResponse({
    required this.success,
    this.data,
  });

  bool success;
  User? data;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json["success"],
        data: User.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": (data == null) ? null : data!.toJson(),
      };
}

LoggedInUser loggedInUserFromJson(String str) =>
    LoggedInUser.fromJson(json.decode(str));

String loggedInUserToJson(LoggedInUser data) => json.encode(data.toJson());

class LoggedInUser {
  LoggedInUser({
    required this.id,
    required this.mobile,
    this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    this.profile,
  });

  int id;
  String mobile;
  String? email;
  String? firstName;
  String? lastName;
  String? avatar;
  Profile? profile;

  factory LoggedInUser.fromJson(Map<String, dynamic> json) => LoggedInUser(
        id: json["id"],
        mobile: json["mobile"],
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        avatar: json["avatar"],
        profile: Profile.fromJson(json["profile"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mobile": mobile,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "avatar": avatar,
        "profile": profile == null ? null : profile!.toJson(),
      };
}

class Profile {
  Profile({
    this.fieldOfStudy,
    this.yob,
    this.city,
    isStudent,
  }) : isStudent = isStudent ?? false;

  int? fieldOfStudy;
  int? yob;
  String? city;
  bool isStudent;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        fieldOfStudy: json["field_of_study"],
        yob: json["yob"],
        city: json["city"],
        isStudent: json["is_student"],
      );

  Map<String, dynamic> toJson() => {
        "field_of_study": fieldOfStudy,
        "yob": yob,
        "city": city,
        "is_student": isStudent,
      };
}
