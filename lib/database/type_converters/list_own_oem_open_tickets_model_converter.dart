import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';

class ListOwnOemOpenTicketsListModelConverter
    extends TypeConverter<List<ListOwnOemOpenTickets>?, String?> {
  @override
  List<ListOwnOemOpenTickets>? decode(String? databaseValue) {
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson
          .map((item) => ListOwnOemOpenTickets.fromJson(item))
          .toList();
    }
    return null;
  }

  @override
  String? encode(List<ListOwnOemOpenTickets>? value) {
    if (value != null) {
      final List<dynamic> listJson =
          value.map((item) => item.toJson()).toList();
      return json.encode(listJson);
    }
    return null;
  }
}
