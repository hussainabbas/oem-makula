import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';

class OemStatusModelConverter extends TypeConverter<OemStatus?, String?> {
  @override
  OemStatus? decode(String? databaseValue) {
    return databaseValue != null
        ? OemStatus.fromJson(json.decode(databaseValue))
        : null;
  }

  @override
  String? encode(OemStatus? value) {
    return value != null ? json.encode(value.toJson()) : null;
  }
}
