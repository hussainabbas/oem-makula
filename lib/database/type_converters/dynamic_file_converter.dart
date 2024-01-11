import 'dart:convert';
import 'package:floor/floor.dart';
import 'package:makula_oem/helper/utils/utils.dart';

class DynamicValueConverter extends TypeConverter<dynamic?, String?> {
  @override
  dynamic? decode(String? databaseValue) {
    console("DynamicValueConverter DECODE => $databaseValue");
    if (databaseValue != null && databaseValue != "") {
      return jsonDecode(databaseValue);
    }
    return "";
  }

  @override
  String? encode(dynamic? value) {
    console("DynamicValueConverter => $value");
    if (value != null) {
      return jsonEncode(value);
    }
    return "";
  }
}