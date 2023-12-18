import 'package:floor/floor.dart';
import 'package:makula_oem/database/type_converters/current_user_converter.dart';
import 'package:makula_oem/database/type_converters/facility_converter.dart';
import 'package:makula_oem/database/type_converters/list_string_converter.dart';
import 'package:makula_oem/database/type_converters/machine_information_converter.dart';
import 'package:makula_oem/helper/model/facilities.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/machine_information.dart';

@entity
class OpenTicket {
  @primaryKey
  String? sId;
  String? title;
  String? ticketId;
  String? ticketType;
  @TypeConverters([CurrentUserConverter])
  @ColumnInfo(name: "assignee")
  CurrentUser? assignee;
  String? description;
  bool? unread;
  String? notes;
  String? chat;
  String? status;
  String? createdAt;
  @TypeConverters([FacilityConverter])
  Facility? facility;
  @TypeConverters([MachineInformationConverter])
  MachineInformation? machine;
  int channelsWithCount = 0;
  @TypeConverters([ListStringConverter])
  List<String>? ticketChatChannels;
  @TypeConverters([ListStringConverter])
  List<String>? ticketInternalNotesChatChannels;
  @TypeConverters([CurrentUserConverter])
  CurrentUser? user;
  String? timeToken;

  OpenTicket(
      {this.sId,
      this.title,
      this.assignee,
      this.ticketId,
      this.ticketType,
      this.description,
      this.user,
      this.notes,
      this.chat,
      this.facility,
      this.machine,
      this.timeToken,
      this.channelsWithCount = 0,
      this.unread,
      this.createdAt,
      this.ticketChatChannels,
      this.ticketInternalNotesChatChannels,
      this.status});

  OpenTicket.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    unread = json['unread'];
    ticketId = json['ticketId'];
    ticketType = json['ticketType'];
    createdAt = json['createdAt'];
    title = json['title'];
    ticketChatChannels = json['ticketChatChannels'].cast<String>();
    ticketInternalNotesChatChannels =
        json['ticketInternalNotesChatChannels'].cast<String>();
    assignee = json['assignee'] != null
        ? CurrentUser.fromJson(json['assignee'])
        : null;
    description = json['description'];
    notes = json['notes'];
    timeToken = json['timeToken'];
    chat = json['chat'];
    facility =
        json['facility'] != null ? Facility.fromJson(json['facility']) : null;
    machine = json['machine'] != null
        ? MachineInformation.fromJson(json['machine'])
        : null;
    user = json['user'] != null ? CurrentUser.fromJson(json['user']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['unread'] = unread;
    data['createdAt'] = createdAt;
    data['title'] = title;
    data['ticketType'] = ticketType;
    data['ticketChatChannels'] = ticketChatChannels;
    data['ticketInternalNotesChatChannels'] = ticketInternalNotesChatChannels;
    data['ticketId'] = ticketId;
    data['description'] = description;
    data['notes'] = notes;
    data['chat'] = chat;
    data['status'] = status;
    data['facility'] = facility;
    data['machine'] = machine;
    data['user'] = user;
    data['channelsWithCount'] = channelsWithCount;
    data['timeToken'] = timeToken;
    return data;
  }
}
