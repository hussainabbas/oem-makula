
import 'package:hive/hive.dart';


part 'login_mobile_oem_response.g.dart';

@HiveType(typeId: 0)
class LoginMobile {
  @HiveField(0)
  String? token;
  @HiveField(1)
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