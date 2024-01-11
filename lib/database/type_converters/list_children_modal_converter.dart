import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';

class ListChildrenModalConverter
    extends TypeConverter<List<ChildrenModel>?, String?> {
  @override
  List<ChildrenModel>? decode(String? databaseValue) {
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson.map((item) => ChildrenModel.fromJson(item)).toList();
    }
    return null;
  }

  @override
  String? encode(List<ChildrenModel>? value) {
    if (value != null) {
      final List<dynamic> listJson =
          value.map((item) => item.toJson2()).toList();
      return json.encode(listJson);
    }
    return null;
  }
}
