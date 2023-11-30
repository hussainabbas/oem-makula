// ignore_for_file: constant_identifier_names

import 'package:hive/hive.dart';
import 'package:makula_oem/helper/model/list_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_open_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_open_tickets_model.dart';
import 'package:makula_oem/helper/utils/offline_resources.dart';

import '../model/get_current_user_details_model.dart';
import '../model/get_status_response.dart';
import '../model/login_mobile_oem_response.dart';

class HiveResources {
  HiveResources._();

  static Box<LoginMobile>? loginBox;
  static Box<CurrentUser>? currentUserBox;
  static Box<StatusData>? oemStatusBox;
  static Box<ListUserOpenTickets>? listUserOpenTicketsBox;
  static Box<ListUserCloseTickets>? listUserCloseTicketsBox;
  static Box<ListOpenTickets>? listOpenTicketBox;
  static Box<ListCloseTickets>? listCloseTicketBox;

  static Future<void> init() async {
    loginBox = await Hive.openBox<LoginMobile>(OfflineResources.LOGIN_TOKEN_BOX);
    currentUserBox = await Hive.openBox<CurrentUser>(OfflineResources.CURRENT_USER_BOX);
    oemStatusBox = await Hive.openBox<StatusData>(OfflineResources.OEM_STATUS_BOX);
    listUserOpenTicketsBox = await Hive.openBox<ListUserOpenTickets>(OfflineResources.LIST_USER_OPEN_TICKETS_BOX);
    listUserCloseTicketsBox = await Hive.openBox<ListUserCloseTickets>(OfflineResources.LIST_USER_CLOSE_TICKETS_BOX);
    listOpenTicketBox = await Hive.openBox<ListOpenTickets>(OfflineResources.LIST_OPEN_TICKETS_BOX);
    listCloseTicketBox = await Hive.openBox<ListCloseTickets>(OfflineResources.LIST_CLOSE_TICKETS_BOX);
  }

  static flush() {
    loginBox?.flush();
    currentUserBox?.flush();
    oemStatusBox?.flush();
    listUserOpenTicketsBox?.flush();
    listUserCloseTicketsBox?.flush();
    listOpenTicketBox?.flush();
    listCloseTicketBox?.flush();
  }
}
