class DocumentsModel {
  String? sId;
  String? label;
  String? href;
  bool? visibleForFacility;

  DocumentsModel({this.sId, this.label, this.href, this.visibleForFacility});

  DocumentsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    label = json['label'];
    href = json['href'];
    visibleForFacility = json['visibleForFacility'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['label'] = label;
    data['href'] = href;
    data['visibleForFacility'] = visibleForFacility;
    return data;
  }
}
