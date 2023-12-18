


import 'package:floor/floor.dart';
import 'package:makula_oem/database/type_converters/open_ticket_converter.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';

@entity
class ListOpenTickets {
  @primaryKey
  int? id;

  @TypeConverters([ListOpenTicketConverter])
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