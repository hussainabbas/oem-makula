
import 'package:makula_oem/helper/model/list_all_machines.dart';

class GetMachinesResponse {
  List<ListMachines>? listOwnOemMachines;

  GetMachinesResponse({this.listOwnOemMachines});

  GetMachinesResponse.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemMachines'] != null) {
      listOwnOemMachines = <ListMachines>[];
      json['listOwnOemMachines'].forEach((v) {
        listOwnOemMachines!.add(ListMachines.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listOwnOemMachines != null) {
      data['listOwnOemMachines'] =
          listOwnOemMachines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
