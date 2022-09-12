import 'package:makula_oem/helper/model/chat_keys.dart';

class CurrentUser {
  String? sId;
  String? name;
  String? username;
  String? role;
  String? email;
  String? info;
  String? token;
  String? refreshToken;
  String? foldersAccessToken;

  //String? facility;
  //Oem? oem;
  bool? access;
  String? userType;
  String? phone;
  String? about;
  bool? userCredentialsSent;
  bool? isOem;
  bool? emailNotification;
  int? totalActiveTickets;
  String? organizationName;
  String? organizationType;
  String? chatToken;

  //ChatUUIDMetadata? chatUUIDMetadata;
  ChatKeys? chatKeys;
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
