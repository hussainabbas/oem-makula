
import 'package:floor/floor.dart';
import 'package:makula_oem/database/type_converters/chat_keys_converter.dart';
import 'package:makula_oem/helper/model/chat_keys.dart';

@entity
class CurrentUser {
  @primaryKey
  String? sId;
  String? name;
  String? username;
  String? role;
  String? email;
  String? info;
  String? organizationType;
  String? notificationChannelGroupName;
  String? organizationName;
  String? chatToken;
  String? notificationChannel;
  String? chatUUID;

  @TypeConverters([ChatKeysConverter])
  ChatKeys? chatKeys;

  CurrentUser(
      {this.sId,
        this.name,
        this.username,
        this.role,
        this.email,
        this.info,
        this.organizationType,
        this.notificationChannelGroupName,
        this.organizationName,
        this.chatToken,
        this.chatUUID,
        this.notificationChannel, this.chatKeys});

  CurrentUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    chatUUID = json['chatUUID'];
    name = json['name'];
    username = json['username'];
    role = json['role'];
    email = json['email'];
    info = json['info'];
    organizationType = json['organizationType'];
    notificationChannelGroupName = json['notificationChannelGroupName'];
    organizationName = json['organizationName'];
    chatToken = json['chatToken'];
    notificationChannel = json['notificationChannel'];
    chatKeys =
        json['chatKeys'] != null ? ChatKeys.fromJson(json['chatKeys']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['username'] = username;
    data['role'] = role;
    data['email'] = email;
    data['info'] = info;
    data['organizationType'] = organizationType;
    data['notificationChannelGroupName'] = notificationChannelGroupName;
    data['organizationName'] = organizationName;
    data['chatToken'] = chatToken;
    data['notificationChannel'] = notificationChannel;
    if (chatKeys != null) {
      data['chatKeys'] = chatKeys!.toJson();
    }
    data['chatUUID'] = chatUUID;
    return data;
  }
}
