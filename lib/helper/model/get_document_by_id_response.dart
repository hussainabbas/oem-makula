class GetDocumentByIdResponse {
  GetOwnOemSubmissionById? getOwnOemSubmissionById;

  GetDocumentByIdResponse({this.getOwnOemSubmissionById});

  GetDocumentByIdResponse.fromJson(Map<String, dynamic> json) {
    getOwnOemSubmissionById = json['getOwnOemSubmissionById'] != null
        ? new GetOwnOemSubmissionById.fromJson(json['getOwnOemSubmissionById'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.getOwnOemSubmissionById != null) {
      data['getOwnOemSubmissionById'] = this.getOwnOemSubmissionById!.toJson();
    }
    return data;
  }
}

class GetOwnOemSubmissionById {
  String? id;
  String? templateId;
  String? batchId;
  String? state;
  bool? test;
  String? editable;
  bool? expired;
  String? expiresAt;
  String? password;
  Metadata? metadata;
  String? processedAt;
  String? pdfHash;
  String? downloadUrl;
  String? permanentDownloadUrl;

  GetOwnOemSubmissionById(
      {this.id,
      this.templateId,
      this.batchId,
      this.state,
      this.test,
      this.editable,
      this.expired,
      this.expiresAt,
      this.password,
      this.metadata,
      this.processedAt,
      this.pdfHash,
      this.downloadUrl,
      this.permanentDownloadUrl});

  GetOwnOemSubmissionById.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    templateId = json['template_id'];
    batchId = json['batch_id'];
    state = json['state'];
    test = json['test'];
    editable = json['editable'];
    expired = json['expired'];
    expiresAt = json['expires_at'];
    password = json['password'];
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
    processedAt = json['processed_at'];
    pdfHash = json['pdf_hash'];
    downloadUrl = json['download_url'];
    permanentDownloadUrl = json['permanent_download_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['template_id'] = this.templateId;
    data['batch_id'] = this.batchId;
    data['state'] = this.state;
    data['test'] = this.test;
    data['editable'] = this.editable;
    data['expired'] = this.expired;
    data['expires_at'] = this.expiresAt;
    data['password'] = this.password;

    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    data['processed_at'] = this.processedAt;

    data['pdf_hash'] = this.pdfHash;
    data['download_url'] = this.downloadUrl;
    data['permanent_download_url'] = this.permanentDownloadUrl;
    return data;
  }
}

class Metadata {
  String? oemId;
  String? userId;
  String? machineId;
  String? facilityId;
  String? templateName;
  String? inspectionDate;

  Metadata(
      {this.oemId,
      this.userId,
      this.machineId,
      this.facilityId,
      this.templateName,
      this.inspectionDate});

  Metadata.fromJson(Map<String, dynamic> json) {
    oemId = json['oemId'];
    userId = json['userId'];
    machineId = json['machineId'];
    facilityId = json['facilityId'];
    templateName = json['templateName'];
    inspectionDate = json['inspectionDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['oemId'] = this.oemId;
    data['userId'] = this.userId;
    data['machineId'] = this.machineId;
    data['facilityId'] = this.facilityId;
    data['templateName'] = this.templateName;
    data['inspectionDate'] = this.inspectionDate;
    return data;
  }
}
