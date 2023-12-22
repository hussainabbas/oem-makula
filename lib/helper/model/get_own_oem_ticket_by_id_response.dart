import 'package:floor/floor.dart';
import 'package:makula_oem/database/type_converters/list_procedures_converter.dart';
import 'package:makula_oem/database/type_converters/procedure_converter.dart';

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

  @TypeConverters([ListProceduresConverter])
  List<Procedures>? procedures;

  GetOwnOemTicketById(
      {this.sId,
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
      this.ticketChatChannels});

  GetOwnOemTicketById.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    ticketId = json['ticketId'];
    title = json['title'];
    user = json['user'] != null ? CurrentUser.fromJson(json['user']) : null;
    assignee = json['assignee'] != null
        ? CurrentUser.fromJson(json['assignee'])
        : null;
    // // oem = json['oem'] != null ? Oem.fromJson(json['oem']) : null;
    facility =
        json['facility'] != null ? Facility.fromJson(json['facility']) : null;

    machine = json['machine'] != null
        ? MachineInformation.fromJson(json['machine'])
        : null;
    description = json['description'];
    notes = json['notes'];
    chat = json['chat'];
    status = json['status'];
    createdAt = json['createdAt'];
    ticketChatChannels = json['ticketChatChannels'].cast<String>();

    if (json['procedures'] != null) {
      procedures = <Procedures>[];
      json['procedures'].forEach((v) {
        procedures!.add(Procedures.fromJson(v));
      });
    }
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

    if (procedures != null) {
      data['procedures'] = procedures!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@entity
class Procedures {
  @primaryKey
  int? id;

  @TypeConverters([ProcedureConverter])
  Procedure? procedure;

  Procedures({this.procedure, this.id});

  Procedures.fromJson(Map<String, dynamic> json) {
    procedure = json['procedure'] != null
        ? Procedure.fromJson(json['procedure'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (procedure != null) {
      data['procedure'] = procedure!.toJson();
    }
    return data;
  }
}

@entity
class Procedure {
  @primaryKey
  String? sId;
  String? name;
  String? description;
  String? state;
  String? createdAt;
  String? updatedAt;
  String? pdfUrl;

  Procedure(
      {this.sId,
      this.name,
      this.description,
      this.state,
      this.createdAt,
      this.updatedAt,
      this.pdfUrl});

  Procedure.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    state = json['state'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    pdfUrl = json['pdfUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['state'] = state;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['pdfUrl'] = pdfUrl;
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
