import 'package:makula_oem/helper/model/child_document_model.dart';

class DocumentsDetailsModel {
  String? sId;
  String? treeId;
  String? type;
  String? label;
  bool? hasChild;
  int? numberOfChilds;
  List<ChildDocumentsModel>? childs;

  DocumentsDetailsModel(
      {sId, treeId, type, label, hasChild, numberOfChilds, childs});

  DocumentsDetailsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    treeId = json['treeId'];
    type = json['type'];
    label = json['label'];
    hasChild = json['hasChild'];
    numberOfChilds = json['numberOfChilds'];
    if (json['childs'] != null) {
      childs = <ChildDocumentsModel>[];
      json['childs'].forEach((v) {
        childs!.add(ChildDocumentsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['treeId'] = treeId;
    data['type'] = type;
    data['label'] = label;
    data['hasChild'] = hasChild;
    data['numberOfChilds'] = numberOfChilds;
    if (childs != null) {
      data['childs'] = childs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
