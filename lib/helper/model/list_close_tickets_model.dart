

import 'package:floor/floor.dart';
import 'package:makula_oem/database/type_converters/open_ticket_converter.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';

@entity
class ListCloseTickets {
  @primaryKey
  int? id;

  @TypeConverters([ListOpenTicketConverter])
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
