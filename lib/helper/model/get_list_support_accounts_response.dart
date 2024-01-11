class GetListSupportAccountsResponse {
  List<ListOwnOemSupportAccounts>? listOwnOemSupportAccounts;

  GetListSupportAccountsResponse({this.listOwnOemSupportAccounts});

  GetListSupportAccountsResponse.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemSupportAccounts'] != null) {
      listOwnOemSupportAccounts = <ListOwnOemSupportAccounts>[];
      json['listOwnOemSupportAccounts'].forEach((v) {
        listOwnOemSupportAccounts!
            .add(new ListOwnOemSupportAccounts.fromJson(v));
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

class ListOwnOemSupportAccounts {
  String? sId;
  String? name;
  String? username;

  ListOwnOemSupportAccounts({this.sId, this.name, this.username});

  ListOwnOemSupportAccounts.fromJson(Map<String, dynamic> json) {
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
