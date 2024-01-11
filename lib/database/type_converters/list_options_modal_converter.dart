import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';

class ListOptionsModelConverter
    extends TypeConverter<List<OptionsModel>?, String?> {
  @override
  List<OptionsModel>? decode(String? databaseValue) {
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson.map((item) => OptionsModel.fromJson(item)).toList();
    }
    return null;
  }

  @override
  String? encode(List<OptionsModel>? value) {
    if (value != null) {
      final List<dynamic> listJson =
          value.map((item) => item.toJson()).toList();
      return json.encode(listJson);
    }
    return null;
  }
}
