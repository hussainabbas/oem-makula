import 'package:makula_oem/helper/model/oem.dart';

class GeneralResponse {
  String? success;

  GeneralResponse({this.success});

  GeneralResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    return data;
  }
}
