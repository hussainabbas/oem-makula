import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/chat_keys.dart';
import 'package:makula_oem/helper/model/oem.dart';

class OemConverter extends TypeConverter<Oem?, String?> {
  @override
  Oem? decode(String? databaseValue) {
    if (databaseValue != null) {
      final Map<String, dynamic> map = json.decode(databaseValue);
      return Oem.fromJson(map);
    }
    return null;
  }

  @override
  String? encode(Oem? value) {
    if (value != null) {
      return json.encode(value.toJson());
    }
    return null;
  }
}
