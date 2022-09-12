import 'package:makula_oem/helper/model/customers.dart';
import 'package:makula_oem/helper/model/documents_tree_model.dart';
import 'package:makula_oem/helper/model/oem.dart';

class GetOwnCustomerMachineById {
  String? sId;
  String? name;
  String? serialNumber;
  String? description;
  String? documentationFiles;
  String? issues;
  Oem? oem;
  String? image;
  String? thumbnail;
  int? totalOpenTickets;
  String? slug;
  List<Customers>? customers;
  DocumentTreeModel? documentTree;

  GetOwnCustomerMachineById(
      {sId,
      name,
      serialNumber,
      description,
      documentationFiles,
      issues,
      oem,
      image,
      documentTree,
      customers,
      documents,
      thumbnail,
      totalOpenTickets,
      slug});

  GetOwnCustomerMachineById.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    serialNumber = json['serialNumber'];
    description = json['description'];
    documentationFiles = json['documentationFiles'];
    issues = json['issues'];
    oem = json['oem'] != null ? Oem.fromJson(json['oem']) : null;
    if (json['customers'] != null) {
      customers = <Customers>[];
      json['customers'].forEach((v) {
        customers!.add(Customers.fromJson(v));
      });
    }
    documentTree = json['documentTree'] != null
        ? DocumentTreeModel.fromJson(json['documentTree'])
        : null;
    image = json['image'];
    thumbnail = json['thumbnail'];
    totalOpenTickets = json['totalOpenTickets'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['serialNumber'] = serialNumber;
    data['description'] = description;
    data['documentationFiles'] = documentationFiles;
    data['issues'] = issues;
    if (oem != null) {
      data['oem'] = oem!.toJson();
    }
    if (documentTree != null) {
      data['documentTree'] = documentTree!.toJson();
    }
    if (customers != null) {
      data['customers'] = customers!.map((v) => v.toJson()).toList();
    }
    data['image'] = image;
    data['thumbnail'] = thumbnail;
    data['totalOpenTickets'] = totalOpenTickets;
    data['slug'] = slug;
    return data;
  }
}
