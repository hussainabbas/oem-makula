import 'package:hive/hive.dart';
import 'package:makula_oem/helper/model/facilities.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/machine_information.dart';

part 'open_ticket_model.g.dart';

@HiveType(typeId: 8)
class OpenTicket {
  @HiveField(0)
  String? sId;
  @HiveField(1)
  String? title;
  @HiveField(2)
  String? ticketId;
  @HiveField(3)
  String? ticketType;
  @HiveField(4)
  CurrentUser? assignee;
  @HiveField(5)
  String? description;
  @HiveField(6)
  bool? unread;
  @HiveField(7)
  String? notes;
  @HiveField(8)
  String? chat;
  @HiveField(9)
  String? status;
  @HiveField(10)
  String? createdAt;
  @HiveField(11)
  Facility? facility;
  @HiveField(12)
  MachineInformation? machine;
  @HiveField(13)
  int channelsWithCount = 0;
  @HiveField(14)
  List<String>? ticketChatChannels;
  @HiveField(15)
  List<String>? ticketInternalNotesChatChannels;
  @HiveField(16)
  CurrentUser? user;
  @HiveField(17)
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
