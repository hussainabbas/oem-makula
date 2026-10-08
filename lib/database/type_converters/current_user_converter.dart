import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/chat_keys.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';

class CurrentUserConverter extends TypeConverter<CurrentUser?, String?> {
  @override
  CurrentUser? decode(String? databaseValue) {
    if (databaseValue != null) {
      final Map<String, dynamic> map = json.decode(databaseValue);
      return CurrentUser.fromJson(map);
    }
    return null;
  }

  @override
  String? encode(CurrentUser? value) {
    if (value != null) {
      return json.encode(value.toJson());
    }
    return null;
  }
}
