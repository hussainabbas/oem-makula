import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/chat_keys.dart';
import 'package:makula_oem/helper/model/facilities.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';

class FacilityConverter extends TypeConverter<Facility?, String?> {
  @override
  Facility? decode(String? databaseValue) {
    if (databaseValue != null) {
      final Map<String, dynamic> map = json.decode(databaseValue);
      return Facility.fromJson(map);
    }
    return null;
  }

  @override
  String? encode(Facility? value) {
    if (value != null) {
      return json.encode(value.toJson());
    }
    return null;
  }
}
