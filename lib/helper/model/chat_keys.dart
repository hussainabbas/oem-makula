import 'package:hive/hive.dart';

part 'chat_keys.g.dart';

@HiveType(typeId: 2)
class ChatKeys {
  @HiveField(0)
  String? subscribeKey;
  @HiveField(1)
  String? publishKey;

  ChatKeys({this.subscribeKey, this.publishKey});

  ChatKeys.fromJson(Map<dynamic, dynamic> json) {
    subscribeKey = json['subscribeKey'];
    publishKey = json['publishKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subscribeKey'] = subscribeKey;
    data['publishKey'] = publishKey;
    return data;
  }
}
