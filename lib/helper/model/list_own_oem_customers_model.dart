
import 'package:makula_oem/helper/model/list_customers.dart';

class OwnOemCustomersModel {
  List<ListOwnOemCustomers>? listOwnOemCustomers;

  OwnOemCustomersModel({this.listOwnOemCustomers});

  OwnOemCustomersModel.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemCustomers'] != null) {
      listOwnOemCustomers = <ListOwnOemCustomers>[];
      json['listOwnOemCustomers'].forEach((v) {
        listOwnOemCustomers!.add(ListOwnOemCustomers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listOwnOemCustomers != null) {
      data['listOwnOemCustomers'] =
          listOwnOemCustomers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}