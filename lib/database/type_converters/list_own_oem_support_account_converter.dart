import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';

import '../../helper/model/get_list_support_accounts_response.dart';
import '../../helper/model/list_assignee_response.dart';

class ListOwnOemSupportAccountsConverter
    extends TypeConverter<List<ListOwnOemSupportAccounts>?, String?> {
  @override
  List<ListOwnOemSupportAccounts>? decode(String? databaseValue) {
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson.map((item) => ListOwnOemSupportAccounts.fromJson(item)).toList();
    }
    return null;
  }

  @override
  String? encode(List<ListOwnOemSupportAccounts>? value) {
    if (value != null) {
      final List<dynamic> listJson =
          value.map((item) => item.toJson()).toList();
      return json.encode(listJson);
    }
    return null;
  }
}
