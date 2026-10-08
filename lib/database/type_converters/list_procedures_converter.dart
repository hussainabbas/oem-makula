import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_own_oem_ticket_by_id_response.dart';
import 'package:makula_oem/helper/model/list_assignee_response.dart';
import 'package:makula_oem/helper/utils/utils.dart';

// class ListProceduresConverter
//     extends TypeConverter<List<Procedures>?, String?> {
//   @override
//   List<Procedures>? decode(String? databaseValue) {
//     if (databaseValue != null) {
//       final List<dynamic> listJson = json.decode(databaseValue);
//       return listJson
//           .map((item) => Procedures.fromJson(item))
//           .toList();
//     }
//     return null;
//   }
//
//   @override
//   String? encode(List<Procedures>? value) {
//     if (value != null) {
//       final List<dynamic> listJson =
//           value.map((item) => item.toJson()).toList();
//       return json.encode(listJson);
//     }
//     return null;
//   }
// }

class ListProceduresConverter
    extends TypeConverter<List<Procedures>?, String?> {
  @override
  List<Procedures>? decode(String? databaseValue) {
    console('ListProceduresConverter DECODE: $databaseValue');
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson
          .map((item) => Procedures.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  String? encode(List<Procedures>? value) {
    console('ListProceduresConverter ENCODE: $value');
    if (value != null) {
      final List<dynamic> listJson =
      value.map((item) => item.toJson()).toList();
      return json.encode(listJson);
    }
    return null;
  }
}