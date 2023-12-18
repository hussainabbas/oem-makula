import 'dart:async';

import 'package:floor/floor.dart';
import 'package:makula_oem/database/current_user_dao.dart';
import 'package:makula_oem/database/get_oem_statuses_response_dao.dart';
import 'package:makula_oem/database/get_ticket_details_response_dao.dart';
import 'package:makula_oem/database/list_close_tickets_dao.dart';
import 'package:makula_oem/database/list_open_tickets_dao.dart';
import 'package:makula_oem/database/list_user_close_tickets_dao.dart';
import 'package:makula_oem/database/list_user_open_tickets_dao.dart';
import 'package:makula_oem/database/login_mobile_dao.dart';
import 'package:makula_oem/database/type_converters/chat_keys_converter.dart';
import 'package:makula_oem/database/type_converters/current_user_converter.dart';
import 'package:makula_oem/database/type_converters/facility_converter.dart';
import 'package:makula_oem/database/type_converters/list_assignee_dao.dart';
import 'package:makula_oem/database/type_converters/list_own_oem_open_tickets_model_converter.dart';
import 'package:makula_oem/database/type_converters/list_own_oem_support_accounts_converter.dart';
import 'package:makula_oem/database/type_converters/list_string_converter.dart';
import 'package:makula_oem/database/type_converters/machine_information_converter.dart';
import 'package:makula_oem/database/type_converters/oem_status_model_converter.dart';
import 'package:makula_oem/database/type_converters/open_ticket_converter.dart';
import 'package:makula_oem/database/type_converters/statuses_model_converter.dart';
import 'package:makula_oem/helper/model/facilities.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';
import 'package:makula_oem/helper/model/list_assignee_response.dart';
import 'package:makula_oem/helper/model/list_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_open_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_open_tickets_model.dart';
import 'package:makula_oem/helper/model/login_mobile_oem_response.dart';
import 'package:makula_oem/helper/model/machine_information.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../helper/model/get_own_oem_ticket_by_id_response.dart';

part 'app_database.g.dart';

@Database(version: 3, entities: [
  LoginMobile,
  CurrentUser,
  StatusData,
  ListOwnOemOpenTickets,
  OemStatus,
  Statuses,
  ListUserOpenTickets,
  Facility,
  MachineInformation,
  ListUserCloseTickets,
  GetOwnOemTicketById,
  ListOpenTickets,
  ListCloseTickets,
  ListAssignee,
  ListOwnOemSupportAccounts
])
@TypeConverters([
  ChatKeysConverter,
  ListOwnOemOpenTicketsListModelConverter,
  OemStatusModelConverter,
  StatusesListModelConverter,
  CurrentUserConverter,
  FacilityConverter,
  MachineInformationConverter,
  ListStringConverter,
  ListStringConverter2,
  ListOwnOemOpenTicketsListModelConverter,
])
abstract class AppDatabase extends FloorDatabase {
  LoginMobileDao get loginMobileDao;

  CurrentUserDao get userDao;

  GetOemStatusesResponseDao get oemStatusDao;

  ListUserOpenTicketsDao get userOpenTicketListDao;

  ListUserCloseTicketsDao get userCloseTicketListDao;

  ListOpenTicketsDao get listOpenTicketsDao;

  ListCloseTicketsDao get listCloseTicketsDao;

  GetTicketDetailResponseDao get getTicketDetailResponseDao;

  ListAssigneeDao get getListAssignee;
}
