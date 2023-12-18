
import 'package:floor/floor.dart';
import 'package:makula_oem/database/type_converters/open_ticket_converter.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';


@entity
class ListUserOpenTickets {
  @primaryKey
  int? id;

  @TypeConverters([ListOpenTicketConverter])
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