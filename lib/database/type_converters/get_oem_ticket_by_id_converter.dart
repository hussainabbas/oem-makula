import 'dart:convert';

import 'package:floor/floor.dart';

import '../../helper/model/get_own_oem_ticket_by_id_response.dart';

class GetOemTicketByIdConverter
    extends TypeConverter<GetOwnOemTicketById?, String?> {
  @override
  GetOwnOemTicketById? decode(String? databaseValue) {
    if (databaseValue != null) {
      final Map<String, dynamic> map = json.decode(databaseValue);
      return GetOwnOemTicketById.fromJson(map);
    }
    return null;
  }

  @override
  String? encode(GetOwnOemTicketById? value) {
    if (value != null) {
      return json.encode(value.toJson());
    }
    return null;
  }
}
