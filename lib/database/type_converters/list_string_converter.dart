import 'dart:convert';

import 'package:floor/floor.dart';
class ListStringConverter2 extends TypeConverter<List<String>?, String?> {
  @override
  List<String>? decode(String? databaseValue) {
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson.cast<String>();
    }
    return null;
  }

  @override
  String? encode(List<String>? value) {
    if (value != null) {
      final List<dynamic> listJson = value.toList();
      return json.encode(listJson);
    }
    return null;
  }
}


class ListStringConverter extends TypeConverter<List<String>, String> {
  @override
  List<String> decode(String databaseValue) {
    return databaseValue.split(',');
  }

  @override
  String encode(List<String> value) {
    return value.join(',');
  }
}