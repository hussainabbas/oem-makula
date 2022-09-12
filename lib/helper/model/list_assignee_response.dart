class ListAssignee {
  List<ListOwnOemSupportAccounts>? listOwnOemSupportAccounts;

  ListAssignee({this.listOwnOemSupportAccounts});

  ListAssignee.fromJson(Map<String, dynamic> json) {
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['username'] = this.username;
    data['role'] = this.role;
    data['email'] = this.email;
    data['access'] = this.access;
    data['userType'] = this.userType;
    data['userCredentialsSent'] = this.userCredentialsSent;
    data['isOem'] = this.isOem;
    data['emailNotification'] = this.emailNotification;
    data['totalActiveTickets'] = this.totalActiveTickets;
    data['organizationName'] = this.organizationName;
    data['organizationType'] = this.organizationType;
    return data;
  }
}
