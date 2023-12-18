import 'package:floor/floor.dart';
import 'package:makula_oem/database/type_converters/get_oem_ticket_by_id_converter.dart';

import '../../database/type_converters/current_user_converter.dart';
import '../../database/type_converters/facility_converter.dart';
import '../../database/type_converters/list_string_converter.dart';
import '../../database/type_converters/machine_information_converter.dart';
import 'facilities.dart';
import 'get_current_user_details_model.dart';
import 'machine_information.dart';

// @TypeConverters([GetOemTicketByIdConverter])
@entity
class GetOwnOemTicketById {
  @primaryKey
  String? sId;
  String? ticketId;
  String? title;

  @TypeConverters([CurrentUserConverter])
  CurrentUser? user;

  @TypeConverters([CurrentUserConverter])
  CurrentUser? assignee;

  // @TypeConverters([OemConverter])
  // Oem? oem;

  @TypeConverters([FacilityConverter])
  Facility? facility;

  @TypeConverters([MachineInformationConverter])
  MachineInformation? machine;

  String? description;
  String? notes;
  String? chat;
  String? status;
  String? createdAt;

  @TypeConverters([ListStringConverter2])
  List<String>? ticketChatChannels;

  GetOwnOemTicketById({
    this.sId,
    this.ticketId,
    this.title,
    this.user,
    this.assignee,
    // oem,
    this.facility,
    this.description,
    this.notes,
    this.chat,
    this.status,
    this.createdAt,
    this.machine,
    this.ticketChatChannels
  });

  GetOwnOemTicketById.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    ticketId = json['ticketId'];
    title = json['title'];
    user = json['user'] != null ? CurrentUser.fromJson(json['user']) : null;
    assignee = json['assignee'] != null ? CurrentUser.fromJson(json['assignee']) : null;
    // // oem = json['oem'] != null ? Oem.fromJson(json['oem']) : null;
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
    ticketChatChannels = json['ticketChatChannels'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['ticketId'] = ticketId;
    data['title'] = title;
    data['user'] = user;
    data['assignee'] = assignee;
    // if (oem != null) {
    //   data['oem'] = oem!.toJson();
    // }

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
    data['machine'] = machine;
    data['ticketChatChannels'] = ticketChatChannels;
    return data;
  }
}

// @entity
// class GetOwnOemTicketById {
//   @primaryKey
//   String? id;
//   String? ticketId;
//   String? title;
//
//   @TypeConverters([CurrentUserConverter])
//   CurrentUser? user;
//
//   @TypeConverters([CurrentUserConverter])
//   CurrentUser? assignee;
//
//   // @TypeConverters([OemConverter])
//   // Oem? oem;
//
//   @TypeConverters([FacilityConverter])
//   Facility? facility;
//
//   @TypeConverters([MachineInformationConverter])
//   MachineInformation? machine;
//
//   String? description;
//   String? notes;
//   String? chat;
//   String? status;
//   String? createdAt;
//
//   @TypeConverters([ListStringConverter])
//   List<String>? ticketChatChannels;
//
//   // GetOwnOemTicketById({required this.id, this.ticketId});
//     GetOwnOemTicketById({
//       this.id,
//       this.ticketId,
//       this.title,
//       this.user,
//       this.assignee,
//         // oem,
//       this.facility,
//       this.description,
//       this.notes,
//       this.chat,
//       this.status,
//       this.createdAt,
//       this.machine,
//       this.ticketChatChannels
//       });
//
//   static GetOwnOemTicketById fromJson(Map<String, dynamic> json) {
//     return GetOwnOemTicketById(id: json['_id']);
//   }
//
//   Map<String, dynamic> toJson() {
//     return {'_id': id};
//   }
// }
