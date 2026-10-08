import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/chat_keys.dart';

class ChatKeysConverter extends TypeConverter<ChatKeys?, String?> {
  @override
  ChatKeys? decode(String? databaseValue) {
    if (databaseValue != null) {
      final Map<String, dynamic> map = json.decode(databaseValue);
      return ChatKeys.fromJson(map);
    }
    return null;
  }

  @override
  String? encode(ChatKeys? value) {
    if (value != null) {
      return json.encode(value.toJson());
    }
    return null;
  }
}
