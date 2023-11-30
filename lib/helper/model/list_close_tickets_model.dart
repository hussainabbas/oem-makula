import 'package:hive/hive.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';

part 'list_close_tickets_model.g.dart';

@HiveType(typeId: 13)
class ListCloseTickets {
  @HiveField(0)
  List<OpenTicket>? closeTickets;

  ListCloseTickets({this.closeTickets});

  ListCloseTickets.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemClosedTickets'] != null) {
      closeTickets = <OpenTicket>[];
      json['listOwnOemClosedTickets'].forEach((v) {
        closeTickets!.add(OpenTicket.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (closeTickets != null) {
      data['listOwnOemClosedTickets'] =
          closeTickets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
