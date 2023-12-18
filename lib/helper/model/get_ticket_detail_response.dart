
import 'get_own_oem_ticket_by_id_response.dart';


class GetTicketDetailResponse {
  String? id;
  GetOwnOemTicketById? getOwnOemTicketById;

  GetTicketDetailResponse({getOwnOemTicketById});

  GetTicketDetailResponse.fromJson(Map<String, dynamic> json) {
    getOwnOemTicketById = json['getOwnOemTicketById'] != null
        ? GetOwnOemTicketById.fromJson(json['getOwnOemTicketById'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (getOwnOemTicketById != null) {
      data['getOwnOemTicketById'] = getOwnOemTicketById!.toJson();
    }
    return data;
  }
}




