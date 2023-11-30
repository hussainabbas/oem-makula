

import 'package:hive/hive.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';

part 'list_user_close_tickets_model.g.dart';

@HiveType(typeId: 11)
class ListUserCloseTickets {
  @HiveField(0)
  List<OpenTicket>? closeTickets;

  ListUserCloseTickets({this.closeTickets});

  ListUserCloseTickets.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemUserClosedTickets'] != null) {
      closeTickets = <OpenTicket>[];
      json['listOwnOemUserClosedTickets'].forEach((v) {
        closeTickets!.add( OpenTicket.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (closeTickets != null) {
      data['listOwnOemUserClosedTickets'] =
          closeTickets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}