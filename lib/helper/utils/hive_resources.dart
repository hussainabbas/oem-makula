// ignore_for_file: constant_identifier_names

import 'package:makula_oem/helper/model/get_ticket_detail_response.dart';
import 'package:makula_oem/helper/model/list_assignee_response.dart';
import 'package:makula_oem/helper/model/list_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_open_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_open_tickets_model.dart';
import 'package:makula_oem/helper/utils/offline_resources.dart';
import 'package:makula_oem/helper/utils/utils.dart';

import '../model/get_current_user_details_model.dart';
import '../model/get_status_response.dart';
import '../model/login_mobile_oem_response.dart';

// class HiveResources {
//   HiveResources._();
//
//   static Box<LoginMobile>? loginBox;
//   static Box<CurrentUser>? currentUserBox;
//   static Box<StatusData>? oemStatusBox;
//   static Box<ListUserOpenTickets>? listUserOpenTicketsBox;
//   static Box<ListUserCloseTickets>? listUserCloseTicketsBox;
//   static Box<ListOpenTickets>? listOpenTicketBox;
//   static Box<ListCloseTickets>? listCloseTicketBox;
//   static Box<List>? getTicketDetailResponseBox;
//   static Box<ListAssignee>? listAssigneeBox;
//
//   static Future<void> init() async {
//     loginBox = await Hive.openBox<LoginMobile>(OfflineResources.LOGIN_TOKEN_BOX);
//     currentUserBox = await Hive.openBox<CurrentUser>(OfflineResources.CURRENT_USER_BOX);
//     oemStatusBox = await Hive.openBox<StatusData>(OfflineResources.OEM_STATUS_BOX);
//     listUserOpenTicketsBox = await Hive.openBox<ListUserOpenTickets>(OfflineResources.LIST_USER_OPEN_TICKETS_BOX);
//     listUserCloseTicketsBox = await Hive.openBox<ListUserCloseTickets>(OfflineResources.LIST_USER_CLOSE_TICKETS_BOX);
//     listOpenTicketBox = await Hive.openBox<ListOpenTickets>(OfflineResources.LIST_OPEN_TICKETS_BOX);
//     listCloseTicketBox = await Hive.openBox<ListCloseTickets>(OfflineResources.LIST_CLOSE_TICKETS_BOX);
//     getTicketDetailResponseBox = await Hive.openBox<List>(OfflineResources.GET_TICKET_DETAIL_RESPONSE_BOX);
//     listAssigneeBox = await Hive.openBox<ListAssignee>(OfflineResources.LIST_ASSIGNEE_BOX);
//   }
//   static void addTicketDetail(GetTicketDetailResponse ticketDetail) {
//       console("addTicketDetail");
//       console("addTicketDetail1 =? ${getTicketDetailResponseBox?.isNotEmpty}");
//       console("addTicketDetail2 =? ${getTicketDetailResponseBox?.length}");
//       console("addTicketDetail2 =? ${getTicketDetailResponseBox?.length}");
//
//       final ticketDetails = getTicketDetailResponseBox?.get("0", defaultValue: [])?.cast<GetTicketDetailResponse>();
//
//       // Check if the ticket with the given ID already exists
//       final existingTicketIndex = ticketDetails?.indexWhere((ticket) => ticket.getOwnOemTicketById?.sId == ticketDetail.getOwnOemTicketById?.sId) ?? 0;
//       console("addTicketDetail existingTicketIndex =? $existingTicketIndex");
//       if (existingTicketIndex != -1) {
//         // Update the existing ticket data
//         ticketDetails?[existingTicketIndex] = ticketDetail;
//       } else {
//         // Add a new entry
//         ticketDetails?.add(ticketDetail);
//       }
//
//       getTicketDetailResponseBox?.put("0", ticketDetails!.cast<GetTicketDetailResponse>());
//   }
//   static GetTicketDetailResponse? getTicketDetailById(String id) {
//     final ticketDetails = getTicketDetailResponseBox?.get("0", defaultValue: [])?.cast<GetTicketDetailResponse>();
//     console('station box list length is ${ticketDetails?.length}');
//     ticketDetails?.forEach((element) {
//       console('station box list length is ${element.getOwnOemTicketById?.sId.toString()}');
//     });
//     return ticketDetails?.firstWhere((ticket) => ticket.getOwnOemTicketById?.sId == id);
//   }
//   static flush() {
//     loginBox?.close();
//     currentUserBox?.close();
//     oemStatusBox?.close();
//     listUserOpenTicketsBox?.close();
//     listUserCloseTicketsBox?.close();
//     listOpenTicketBox?.close();
//     listCloseTicketBox?.close();
//   }
// }
