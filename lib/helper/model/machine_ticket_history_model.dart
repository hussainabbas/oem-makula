import 'package:makula_oem/helper/model/open_ticket_model.dart';

class MachineTicketHistory {
  List<OpenTicket>? listOwnOemMachineTicketHistoryById;

  MachineTicketHistory({this.listOwnOemMachineTicketHistoryById});

  MachineTicketHistory.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemMachineTicketHistoryById'] != null) {
      listOwnOemMachineTicketHistoryById = <OpenTicket>[];
      json['listOwnOemMachineTicketHistoryById'].forEach((v) {
        listOwnOemMachineTicketHistoryById!.add(OpenTicket.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listOwnOemMachineTicketHistoryById != null) {
      data['listOwnOemMachineTicketHistoryById'] =
          listOwnOemMachineTicketHistoryById!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
