import 'package:makula_oem/helper/model/customers.dart';

class ListOwnCustomerMachines {
  String? sId;
  String? name;
  String? serialNumber;
  String? description;
  String? documentationFiles;
  String? issues;
  String? image;
  String? thumbnail;
  int? totalOpenTickets;
  String? slug;
  List<Customers>? customers;

  ListOwnCustomerMachines(
      {this.sId,
      this.name,
      this.serialNumber,
      this.description,
      this.documentationFiles,
      this.issues,
      this.image,
      this.thumbnail,
      this.customers,
      this.totalOpenTickets,
      this.slug});

  ListOwnCustomerMachines.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    serialNumber = json['serialNumber'];
    description = json['description'];
    documentationFiles = json['documentationFiles'];
    issues = json['issues'];
    if (json['customers'] != null) {
      customers = <Customers>[];
      json['customers'].forEach((v) {
        customers!.add(Customers.fromJson(v));
      });
    }
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
