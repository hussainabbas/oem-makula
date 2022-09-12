

import 'package:makula_oem/helper/model/open_ticket_model.dart';

class ListOpenTickets {
  List<OpenTicket>? openTicket;

  ListOpenTickets({this.openTicket});

  ListOpenTickets.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemOpenTickets'] != null) {
      openTicket = <OpenTicket>[];
      json['listOwnOemOpenTickets'].forEach((v) {
        openTicket!.add( OpenTicket.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (openTicket != null) {
      data['listOwnOemOpenTickets'] =
          openTicket!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}