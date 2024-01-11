import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';

import '../../helper/model/get_procedure_templates_response.dart';

class ListOwnOemProcedureTemplatesModelConverter
    extends TypeConverter<List<ListOwnOemProcedureTemplates>?, String?> {
  @override
  List<ListOwnOemProcedureTemplates>? decode(String? databaseValue) {
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson
          .map((item) => ListOwnOemProcedureTemplates.fromJson(item))
          .toList();
    }
    return null;
  }

  @override
  String? encode(List<ListOwnOemProcedureTemplates>? value) {
    if (value != null) {
      final List<dynamic> listJson =
          value.map((item) => item.toJson()).toList();
      return json.encode(listJson);
    }
    return null;
  }
}
