import 'package:makula_oem/helper/model/facilities.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/machine_information.dart';
import 'package:makula_oem/helper/model/oem.dart';

class GetTicketDetailResponse {
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

class GetOwnOemTicketById {
  String? sId;
  String? ticketId;
  String? title;
  CurrentUser? user;
  CurrentUser? assignee;
  Oem? oem;
  Facility? facility;
  MachineInformation? machine;
  String? description;
  String? notes;
  String? chat;
  String? status;
  String? createdAt;
  bool? unread;
  bool? isMyTicket;
  List<String>? ticketChatChannels;

  GetOwnOemTicketById(
      {sId,
        ticketId,
        title,
        user,
        assignee,
        oem,
        facility,
        description,
        notes,
        chat,
        status,
        createdAt,
        machine,
        unread,
        isMyTicket,
        ticketChatChannels});

  GetOwnOemTicketById.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    ticketId = json['ticketId'];
    title = json['title'];
    user = json['user'] != null ? CurrentUser.fromJson(json['user']) : null;
    assignee = json['assignee'] != null ? CurrentUser.fromJson(json['assignee']) : null;
    oem = json['oem'] != null ? Oem.fromJson(json['oem']) : null;
    facility = json['facility'] != null
        ? Facility.fromJson(json['facility'])
        : null;

    machine = json['machine'] != null
        ? MachineInformation.fromJson(json['machine'])
        : null;
    description = json['description'];
    notes = json['notes'];
    chat = json['chat'];
    status = json['status'];
    createdAt = json['createdAt'];
    unread = json['unread'];
    isMyTicket = json['isMyTicket'];
    ticketChatChannels = json['ticketChatChannels'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['ticketId'] = ticketId;
    data['title'] = title;
    data['user'] = user;
    data['assignee'] = assignee;
    if (oem != null) {
      data['oem'] = oem!.toJson();
    }

    if (assignee != null) {
      data['assignee'] = assignee!.toJson();
    }
    if (facility != null) {
      data['facility'] = facility!.toJson();
    }
    data['description'] = description;
    data['notes'] = notes;
    data['chat'] = chat;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['unread'] = unread;
    data['isMyTicket'] = isMyTicket;
    data['machine'] = machine;
    data['ticketChatChannels'] = ticketChatChannels;
    return data;
  }
}


