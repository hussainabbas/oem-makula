import 'package:makula_oem/helper/model/list_machines.dart';

class GetMachineListResponse {
  List<ListOwnCustomerMachines>? listOwnCustomerMachines;

  GetMachineListResponse({this.listOwnCustomerMachines});

  GetMachineListResponse.fromJson(Map<String, dynamic> json) {
    if (json['listOwnCustomerMachines'] != null) {
      listOwnCustomerMachines = <ListOwnCustomerMachines>[];
      json['listOwnCustomerMachines'].forEach((v) {
        listOwnCustomerMachines!.add(ListOwnCustomerMachines.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listOwnCustomerMachines != null) {
      data['listOwnCustomerMachines'] =
          listOwnCustomerMachines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
