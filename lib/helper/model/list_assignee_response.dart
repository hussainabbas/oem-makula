
import 'package:floor/floor.dart';
import 'package:makula_oem/database/type_converters/current_user_converter.dart';

import '../../database/type_converters/list_own_oem_support_account_converter.dart';

@entity
class ListAssignee {
  @primaryKey
  String? id;

  @TypeConverters([ListOwnOemSupportAccountsConverter])
  List<ListOwnOemSupportAccounts>? listOwnOemSupportAccounts;

  ListAssignee({this.listOwnOemSupportAccounts});

  ListAssignee.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemSupportAccounts'] != null) {
      listOwnOemSupportAccounts = <ListOwnOemSupportAccounts>[];
      json['listOwnOemSupportAccounts'].forEach((v) {
        listOwnOemSupportAccounts!
            .add(ListOwnOemSupportAccounts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listOwnOemSupportAccounts != null) {
      data['listOwnOemSupportAccounts'] =
          listOwnOemSupportAccounts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@entity
class ListOwnOemSupportAccounts {
  @primaryKey
  String? sId;
  String? name;
  String? username;
  String? role;
  String? email;
  bool? access;
  String? userType;
  bool? userCredentialsSent;
  bool? isOem;
  bool? emailNotification;
  int? totalActiveTickets;
  String? organizationName;
  String? organizationType;

  ListOwnOemSupportAccounts(
      {this.sId,
        this.name,
        this.username,
        this.role,
        this.email,
        this.access,
        this.userType,
        this.userCredentialsSent,
        this.isOem,
        this.emailNotification,
        this.totalActiveTickets,
        this.organizationName,
        this.organizationType});

  ListOwnOemSupportAccounts.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    username = json['username'];
    role = json['role'];
    email = json['email'];
    access = json['access'];
    userType = json['userType'];
    userCredentialsSent = json['userCredentialsSent'];
    isOem = json['isOem'];
    emailNotification = json['emailNotification'];
    totalActiveTickets = json['totalActiveTickets'];
    organizationName = json['organizationName'];
    organizationType = json['organizationType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['username'] = username;
    data['role'] = role;
    data['email'] = email;
    data['access'] = access;
    data['userType'] = userType;
    data['userCredentialsSent'] = userCredentialsSent;
    data['isOem'] = isOem;
    data['emailNotification'] = emailNotification;
    data['totalActiveTickets'] = totalActiveTickets;
    data['organizationName'] = organizationName;
    data['organizationType'] = organizationType;
    return data;
  }
}
