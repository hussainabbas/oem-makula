import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';

import '../../helper/model/get_inventory_part_list_response.dart';
import '../../helper/model/get_list_support_accounts_response.dart';

class SinglePartModelConverter
    extends TypeConverter<List<PartsModel>?, String?> {
  @override
  List<PartsModel>? decode(String? databaseValue) {
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson
          .map((item) => PartsModel.fromJson(item))
          .toList();
    }
    return null;
  }

  @override
  String? encode(List<PartsModel>? value) {
    if (value != null) {
      final List<dynamic> listJson =
      value.map((item) => item.toJson()).toList();
      return json.encode(listJson);
    }
    return null;
  }
}
