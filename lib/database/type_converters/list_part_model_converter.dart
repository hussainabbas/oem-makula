import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/chat_keys.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';

import '../../helper/model/get_inventory_part_list_response.dart';

class ListPartModelConverter extends TypeConverter<ListOwnOemInventoryPartModel?, String?> {
  @override
  ListOwnOemInventoryPartModel? decode(String? databaseValue) {
    if (databaseValue != null) {
      final Map<String, dynamic> map = json.decode(databaseValue);
      return ListOwnOemInventoryPartModel.fromJson(map);
    }
    return null;
  }

  @override
  String? encode(ListOwnOemInventoryPartModel? value) {
    if (value != null) {
      return json.encode(value.toJson());
    }
    return null;
  }
}
