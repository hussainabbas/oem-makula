import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';

import '../../helper/model/get_list_support_accounts_response.dart';

class ListSupportAccountsConverter
    extends TypeConverter<List<ListSupportAccounts>?, String?> {
  @override
  List<ListSupportAccounts>? decode(String? databaseValue) {
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson
          .map((item) => ListSupportAccounts.fromJson(item))
          .toList();
    }
    return null;
  }

  @override
  String? encode(List<ListSupportAccounts>? value) {
    if (value != null) {
      final List<dynamic> listJson =
      value.map((item) => item.toJson()).toList();
      return json.encode(listJson);
    }
    return null;
  }
}
