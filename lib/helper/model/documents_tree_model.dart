import 'package:makula_oem/helper/model/data_tree_facility_mobile.dart';

class DocumentTreeModel {
  String? sId;
  DataTreeFacilityMobile? dataTreeFacilityMobile;

  DocumentTreeModel({this.sId, this.dataTreeFacilityMobile});

  DocumentTreeModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    dataTreeFacilityMobile = json['dataTreeFacilityMobile'] != null
        ? DataTreeFacilityMobile.fromJson(json['dataTreeFacilityMobile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (dataTreeFacilityMobile != null) {
      data['dataTreeFacilityMobile'] = dataTreeFacilityMobile!.toJson();
    }
    return data;
  }
}
