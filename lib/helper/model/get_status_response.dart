

import 'package:floor/floor.dart';
import 'package:makula_oem/database/type_converters/list_own_oem_open_tickets_model_converter.dart';
import 'package:makula_oem/database/type_converters/oem_status_model_converter.dart';
import 'package:makula_oem/database/type_converters/statuses_model_converter.dart';

@entity
class StatusData {
  @primaryKey
  @TypeConverters([ListOwnOemOpenTicketsListModelConverter])
  List<ListOwnOemOpenTickets>? listOwnOemOpenTickets;

  StatusData({this.listOwnOemOpenTickets});

  StatusData.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemOpenTickets'] != null) {
      listOwnOemOpenTickets = <ListOwnOemOpenTickets>[];
      json['listOwnOemOpenTickets'].forEach((v) {
        listOwnOemOpenTickets!.add(ListOwnOemOpenTickets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listOwnOemOpenTickets != null) {
      data['listOwnOemOpenTickets'] =
          listOwnOemOpenTickets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@entity
class ListOwnOemOpenTickets {
  @primaryKey
  int? id;

  @TypeConverters([OemStatusModelConverter])
  OemStatus? oem;

  ListOwnOemOpenTickets({this.oem});

  ListOwnOemOpenTickets.fromJson(Map<String, dynamic> json) {
    oem = json['oem'] != null ? OemStatus.fromJson(json['oem']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (oem != null) {
      data['oem'] = oem!.toJson();
    }
    return data;
  }
}

@entity
class OemStatus {
  @primaryKey
  int? id;

  @TypeConverters([StatusesListModelConverter])
  List<Statuses>? statuses;

  OemStatus({this.statuses});

  OemStatus.fromJson(Map<String, dynamic> json) {
    if (json['statuses'] != null) {
      statuses = <Statuses>[];
      json['statuses'].forEach((v) {
        statuses!.add(Statuses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (statuses != null) {
      data['statuses'] = statuses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Statuses {
  String? sId;
  String? label;
  String? color;

  Statuses({this.sId, this.label, this.color});

  Statuses.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    label = json['label'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['label'] = label;
    data['color'] = color;
    return data;
  }
}
