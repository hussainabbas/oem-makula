import 'package:makula_oem/helper/model/open_ticket_model.dart';

class AddNewTicketResponse {
  OpenTicket? createOwnTicket;

  AddNewTicketResponse({this.createOwnTicket});

  AddNewTicketResponse.fromJson(Map<String, dynamic> json) {
    createOwnTicket = json['createOwnTicket'] != null
        ? OpenTicket.fromJson(json['createOwnTicket'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (createOwnTicket != null) {
      data['createOwnTicket'] = createOwnTicket!.toJson();
    }
    return data;
  }
}
