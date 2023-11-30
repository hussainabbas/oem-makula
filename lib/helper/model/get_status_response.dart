
import 'package:hive/hive.dart';

part 'get_status_response.g.dart';

@HiveType(typeId: 3)
class StatusData {
  @HiveField(0)
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

@HiveType(typeId: 4)
class ListOwnOemOpenTickets {
  @HiveField(0)
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
@HiveType(typeId: 5)
class OemStatus {
  @HiveField(0)
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

@HiveType(typeId: 6)
class Statuses {
  @HiveField(0)
  String? sId;
  @HiveField(1)
  String? label;
  @HiveField(2)
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
