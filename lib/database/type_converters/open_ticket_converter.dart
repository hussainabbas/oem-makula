import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';

class ListOpenTicketConverter
    extends TypeConverter<List<OpenTicket>?, String?> {
  @override
  List<OpenTicket>? decode(String? databaseValue) {
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson.map((item) => OpenTicket.fromJson(item)).toList();
    }
    return null;
  }

  @override
  String? encode(List<OpenTicket>? value) {
    if (value != null) {
      final List<dynamic> listJson =
          value.map((item) => item.toJson()).toList();
      return json.encode(listJson);
    }
    return null;
  }
}
