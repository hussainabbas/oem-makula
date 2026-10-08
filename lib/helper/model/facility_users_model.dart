
import 'package:makula_oem/helper/model/list_facility_users.dart';

class FacilityUsersModel {
  List<ListOwnOemFacilityUsers>? listOwnOemFacilityUsers;

  FacilityUsersModel({this.listOwnOemFacilityUsers});

  FacilityUsersModel.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemFacilityUsers'] != null) {
      listOwnOemFacilityUsers = <ListOwnOemFacilityUsers>[];
      json['listOwnOemFacilityUsers'].forEach((v) {
        listOwnOemFacilityUsers!.add(new ListOwnOemFacilityUsers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listOwnOemFacilityUsers != null) {
      data['listOwnOemFacilityUsers'] =
          this.listOwnOemFacilityUsers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}