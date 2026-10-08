class ListOwnOemFacilityUsers {
  String? sId;
  String? name;
  String? username;
  String? role;
  String? email;
  String? info;
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

  ListOwnOemFacilityUsers(
      {this.sId,
        this.name,
        this.username,
        this.role,
        this.email,
        this.info,
        this.access,
        this.userType,
        this.phone,
        this.about,
        this.userCredentialsSent,
        this.isOem,
        this.emailNotification,
        this.totalActiveTickets,
        this.organizationName,
        this.organizationType});

  ListOwnOemFacilityUsers.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    username = json['username'];
    role = json['role'];
    email = json['email'];
    info = json['info'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['username'] = this.username;
    data['role'] = this.role;
    data['email'] = this.email;
    data['info'] = this.info;
    data['access'] = this.access;
    data['userType'] = this.userType;
    data['phone'] = this.phone;
    data['about'] = this.about;
    data['userCredentialsSent'] = this.userCredentialsSent;
    data['isOem'] = this.isOem;
    data['emailNotification'] = this.emailNotification;
    data['totalActiveTickets'] = this.totalActiveTickets;
    data['organizationName'] = this.organizationName;
    data['organizationType'] = this.organizationType;
    return data;
  }
}