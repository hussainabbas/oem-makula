import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/chat_keys.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';

import '../../helper/model/get_procedure_templates_response.dart';

class ProcedureTemplatesConverter extends TypeConverter<ListOwnOemProcedureTemplates?, String?> {
  @override
  ListOwnOemProcedureTemplates? decode(String? databaseValue) {
    if (databaseValue != null) {
      final Map<String, dynamic> map = json.decode(databaseValue);
      return ListOwnOemProcedureTemplates.fromJson(map);
    }
    return null;
  }

  @override
  String? encode(ListOwnOemProcedureTemplates? value) {
    if (value != null) {
      return json.encode(value.toJson());
    }
    return null;
  }
}
