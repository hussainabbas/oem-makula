
import 'package:makula_oem/helper/model/list_all_machines.dart';
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

class AllOwnOemCustomersModel {
  ListAllOwnOemCustomers? listAllOwnOemCustomers;

  AllOwnOemCustomersModel({this.listAllOwnOemCustomers});

  AllOwnOemCustomersModel.fromJson(Map<String, dynamic> json) {
    listAllOwnOemCustomers = json['listAllOwnOemCustomers'] != null
        ? ListAllOwnOemCustomers.fromJson(json['listAllOwnOemCustomers'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listAllOwnOemCustomers != null) {
      data['listAllOwnOemCustomers'] = listAllOwnOemCustomers!.toJson();
    }
    return data;
  }
}

class ListAllOwnOemCustomers {
  int? totalCount;
  int? limit;
  Null? skip;
  int? currentPage;
  List<Customers>? customers;

  ListAllOwnOemCustomers(
      {this.totalCount,
        this.limit,
        this.skip,
        this.currentPage,
        this.customers});

  ListAllOwnOemCustomers.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    limit = json['limit'];
    skip = json['skip'];
    currentPage = json['currentPage'];
    if (json['customers'] != null) {
      customers = <Customers>[];
      json['customers'].forEach((v) {
        customers!.add(Customers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCount'] = totalCount;
    data['limit'] = limit;
    data['skip'] = skip;
    data['currentPage'] = currentPage;
    if (customers != null) {
      data['customers'] = customers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


