class ListMyDocumentsResponse {
  List<ListOwnOemSubmissions>? listOwnOemSubmissions;

  ListMyDocumentsResponse({this.listOwnOemSubmissions});

  ListMyDocumentsResponse.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemSubmissions'] != null) {
      listOwnOemSubmissions = <ListOwnOemSubmissions>[];
      json['listOwnOemSubmissions'].forEach((v) {
        listOwnOemSubmissions!.add(new ListOwnOemSubmissions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listOwnOemSubmissions != null) {
      data['listOwnOemSubmissions'] =
          this.listOwnOemSubmissions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListOwnOemSubmissions {
  String? sId;
  String? url;
  Machine? machine;
  String? inspectionDate;
  Machine? facility;
  Machine? user;
  Machine? oem;
  String? templateId;
  String? templateName;
  bool? expired;

  ListOwnOemSubmissions(
      {this.sId,
        this.url,
        this.machine,
        this.inspectionDate,
        this.facility,
        this.user,
        this.oem,
        this.templateId,
        this.templateName,
        this.expired});

  ListOwnOemSubmissions.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    url = json['url'];
    machine =
    json['machine'] != null ? new Machine.fromJson(json['machine']) : null;
    inspectionDate = json['inspectionDate'];
    facility = json['facility'] != null
        ? new Machine.fromJson(json['facility'])
        : null;
    user = json['user'] != null ? new Machine.fromJson(json['user']) : null;
    oem = json['oem'] != null ? new Machine.fromJson(json['oem']) : null;
    templateId = json['templateId'];
    templateName = json['templateName'];
    expired = json['expired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['url'] = this.url;
    if (this.machine != null) {
      data['machine'] = this.machine!.toJson();
    }
    data['inspectionDate'] = this.inspectionDate;
    if (this.facility != null) {
      data['facility'] = this.facility!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.oem != null) {
      data['oem'] = this.oem!.toJson();
    }
    data['templateId'] = this.templateId;
    data['templateName'] = this.templateName;
    data['expired'] = this.expired;
    return data;
  }
}

class Machine {
  String? sId;
  String? name;
  String? serialNumber;

  Machine({this.sId, this.name, this.serialNumber});

  Machine.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    serialNumber = json['serialNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['serialNumber'] = this.serialNumber;
    return data;
  }
}

