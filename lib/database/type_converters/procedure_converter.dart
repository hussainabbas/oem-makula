import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/chat_keys.dart';
import 'package:makula_oem/helper/model/get_own_oem_ticket_by_id_response.dart';

class ProcedureConverter extends TypeConverter<Procedure?, String?> {
  @override
  Procedure? decode(String? databaseValue) {
    if (databaseValue != null) {
      final Map<String, dynamic> map = json.decode(databaseValue);
      return Procedure.fromJson(map);
    }
    return null;
  }

  @override
  String? encode(Procedure? value) {
    if (value != null) {
      return json.encode(value.toJson());
    }
    return null;
  }
}
