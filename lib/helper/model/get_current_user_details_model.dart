import 'package:hive/hive.dart';
import 'package:makula_oem/helper/model/chat_keys.dart';

part 'get_current_user_details_model.g.dart';

@HiveType(typeId: 1)
class CurrentUser {
  @HiveField(0)
  String? sId;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? username;
  @HiveField(3)
  String? role;
  @HiveField(4)
  String? email;
  @HiveField(5)
  String? info;
  @HiveField(6)
  String? token;
  @HiveField(7)
  String? refreshToken;
  @HiveField(8)
  String? foldersAccessToken;

  //String? facility;
  //Oem? oem;
  @HiveField(9)
  bool? access;
  @HiveField(10)
  String? userType;
  @HiveField(11)
  String? phone;
  @HiveField(12)
  String? about;
  @HiveField(13)
  bool? userCredentialsSent;
  @HiveField(14)
  bool? isOem;
  @HiveField(15)
  bool? emailNotification;
  @HiveField(16)
  int? totalActiveTickets;
  @HiveField(17)
  String? organizationName;
  @HiveField(18)
  String? organizationType;
  @HiveField(19)
  String? chatToken;

  //ChatUUIDMetadata? chatUUIDMetadata;
  @HiveField(20)
  ChatKeys? chatKeys;
  @HiveField(21)
  String? chatUUID;

  CurrentUser(
      {sId,
      name,
      username,
      role,
      email,
      foldersAccessToken,
      info,
      // facility,
      //oem,
      access,
      token,
      refreshToken,
      userType,
      phone,
      about,
      userCredentialsSent,
      isOem,
      emailNotification,
      totalActiveTickets,
      organizationName,
      organizationType,
      chatToken,
      //chatUUIDMetadata,
      chatKeys,
      chatUUID});

  CurrentUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    username = json['username'];
    foldersAccessToken = json['foldersAccessToken'];
    role = json['role'];
    email = json['email'];
    info = json['info'];
    token = json['token'];
    refreshToken = json['refreshToken'];
    access = json['access'];
    userType = json['userType'];
    phone = json['phone'];
    about = json['about'];
    userCredentialsSent = json['userCredentialsSent'];
    isOem = json['isOem'];
    emailNotification = json['emailNotification'];
    totalActiveTickets = json['totalActiveTickets'];
    organizationName = json['organizationName'];
    organizationType = json['organizationType'];
    chatToken = json['chatToken'];
    chatKeys =
        json['chatKeys'] != null ? ChatKeys.fromJson(json['chatKeys']) : null;
    chatUUID = json['chatUUID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['username'] = username;
    data['role'] = role;
    data['email'] = email;
    data['info'] = info;
    data['foldersAccessToken'] = foldersAccessToken;
    data['refreshToken'] = refreshToken;
    data['token'] = token;
    data['access'] = access;
    data['userType'] = userType;
    data['phone'] = phone;
    data['about'] = about;
    data['userCredentialsSent'] = userCredentialsSent;
    data['isOem'] = isOem;
    data['emailNotification'] = emailNotification;
    data['totalActiveTickets'] = totalActiveTickets;
    data['organizationName'] = organizationName;
    data['organizationType'] = organizationType;
    data['chatToken'] = chatToken;
    if (chatKeys != null) {
      data['chatKeys'] = chatKeys!.toJson();
    }
    data['chatUUID'] = chatUUID;
    return data;
  }
}
