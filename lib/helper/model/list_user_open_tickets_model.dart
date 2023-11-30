

import 'package:hive/hive.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';

part 'list_user_open_tickets_model.g.dart';

@HiveType(typeId: 7)
class ListUserOpenTickets {
  @HiveField(0)
  List<OpenTicket>? openTicket;

  ListUserOpenTickets({this.openTicket});

  ListUserOpenTickets.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemUserOpenTickets'] != null) {
      openTicket = <OpenTicket>[];
      json['listOwnOemUserOpenTickets'].forEach((v) {
        openTicket!.add( OpenTicket.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (openTicket != null) {
      data['listOwnOemUserOpenTickets'] =
          openTicket!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}