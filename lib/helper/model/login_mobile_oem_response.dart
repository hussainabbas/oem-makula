import 'package:floor/floor.dart';


@Entity()
class LoginMobile {
  @PrimaryKey(autoGenerate: true)
  int? id;

  String? token;
  String? refreshToken;

  LoginMobile({this.token , this.refreshToken});

  LoginMobile.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    refreshToken = json['refreshToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['refreshToken'] = refreshToken;
    return data;
  }
}