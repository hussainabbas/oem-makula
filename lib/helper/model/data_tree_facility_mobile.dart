import 'package:makula_oem/helper/model/documents_detail_model.dart';

class DataTreeFacilityMobile {
  String? sId;
  List<DocumentsDetailsModel>? documents;

  DataTreeFacilityMobile({this.sId, this.documents});

  DataTreeFacilityMobile.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['documents'] != null) {
      documents = <DocumentsDetailsModel>[];
      json['documents'].forEach((v) {
        documents!.add(DocumentsDetailsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
