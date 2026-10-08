import 'package:floor/floor.dart';

import '../../database/type_converters/list_own_oem_support_account_converter.dart';

@entity
class GetListSupportAccountsResponse {
  @primaryKey
  @TypeConverters([ListOwnOemSupportAccountsConverter])
  List<ListSupportAccounts>? listOwnOemSupportAccounts;

  GetListSupportAccountsResponse({this.listOwnOemSupportAccounts});

  GetListSupportAccountsResponse.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemSupportAccounts'] != null) {
      listOwnOemSupportAccounts = <ListSupportAccounts>[];
      json['listOwnOemSupportAccounts'].forEach((v) {
        listOwnOemSupportAccounts!.add(new ListSupportAccounts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listOwnOemSupportAccounts != null) {
      data['listOwnOemSupportAccounts'] =
          this.listOwnOemSupportAccounts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@entity
class ListSupportAccounts {
  @primaryKey
  String? sId;
  String? name;
  String? username;

  ListSupportAccounts({this.sId, this.name, this.username});

  ListSupportAccounts.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['username'] = this.username;
    return data;
  }
}
