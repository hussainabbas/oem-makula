import 'package:makula_oem/helper/model/list_all_machines.dart';

class ListOwnOemCustomers {
  String? sId;
  String? name;

  //Oem? oem;
  List<ListMachines>? machines;
  String? urlOemFacility;
  int? totalMachines;
  int? totalOpenTickets;
  bool? isQRCodeEnabled;
  String? generalAccessUrl;

  ListOwnOemCustomers(
      {this.sId,
      this.name,
      //this.oem,
      this.machines,
      this.urlOemFacility,
      this.totalMachines,
      this.totalOpenTickets,
      this.isQRCodeEnabled,
      this.generalAccessUrl});

  ListOwnOemCustomers.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    //oem = json['oem'] != null ? new Oem.fromJson(json['oem']) : null;
    if (json['machines'] != null) {
      machines = <ListMachines>[];
      json['machines'].forEach((v) {
        machines!.add(ListMachines.fromJson(v));
      });
    }
    urlOemFacility = json['urlOemFacility'];
    totalMachines = json['totalMachines'];
    totalOpenTickets = json['totalOpenTickets'];
    isQRCodeEnabled = json['isQRCodeEnabled'];
    generalAccessUrl = json['generalAccessUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    /* if (oem != null) {
      data['oem'] = oem!.toJson();
    }*/
    if (machines != null) {
      data['machines'] = machines!.map((v) => v.toJson()).toList();
    }
    data['urlOemFacility'] = urlOemFacility;
    data['totalMachines'] = totalMachines;
    data['totalOpenTickets'] = totalOpenTickets;
    data['isQRCodeEnabled'] = isQRCodeEnabled;
    data['generalAccessUrl'] = generalAccessUrl;
    return data;
  }
}
