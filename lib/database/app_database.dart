import 'dart:async';

import 'package:floor/floor.dart';
import 'package:makula_oem/database/current_user_dao.dart';
import 'package:makula_oem/database/get_oem_statuses_response_dao.dart';
import 'package:makula_oem/database/get_support_account_dao.dart';
import 'package:makula_oem/database/get_ticket_details_response_dao.dart';
import 'package:makula_oem/database/list_close_tickets_dao.dart';
import 'package:makula_oem/database/list_open_tickets_dao.dart';
import 'package:makula_oem/database/list_user_close_tickets_dao.dart';
import 'package:makula_oem/database/list_user_open_tickets_dao.dart';
import 'package:makula_oem/database/login_mobile_dao.dart';
import 'package:makula_oem/database/part_model_dao.dart';
import 'package:makula_oem/database/procedure_template_dao.dart';
import 'package:makula_oem/database/type_converters/chat_keys_converter.dart';
import 'package:makula_oem/database/type_converters/current_user_converter.dart';
import 'package:makula_oem/database/type_converters/dynamic_file_converter.dart';
import 'package:makula_oem/database/type_converters/facility_converter.dart';
import 'package:makula_oem/database/type_converters/list_assignee_dao.dart';
import 'package:makula_oem/database/type_converters/list_attachment_modal_converter.dart';
import 'package:makula_oem/database/type_converters/list_children_modal_converter.dart';
import 'package:makula_oem/database/type_converters/list_columns_modal_converter.dart';
import 'package:makula_oem/database/type_converters/list_options_modal_converter.dart';
import 'package:makula_oem/database/type_converters/list_own_oem_open_tickets_model_converter.dart';
import 'package:makula_oem/database/type_converters/list_own_oem_support_account_converter.dart';
import 'package:makula_oem/database/type_converters/list_own_procedure_templates_model_converter.dart';
import 'package:makula_oem/database/type_converters/list_part_model_converter.dart';
import 'package:makula_oem/database/type_converters/list_procedures_converter.dart';
import 'package:makula_oem/database/type_converters/list_signature_modal_converter.dart';
import 'package:makula_oem/database/type_converters/list_string_converter.dart';
import 'package:makula_oem/database/type_converters/list_support_account_converter.dart';
import 'package:makula_oem/database/type_converters/machine_information_converter.dart';
import 'package:makula_oem/database/type_converters/oem_status_model_converter.dart';
import 'package:makula_oem/database/type_converters/open_ticket_converter.dart';
import 'package:makula_oem/database/type_converters/procedure_converter.dart';
import 'package:makula_oem/database/type_converters/procedure_template_converter.dart';
import 'package:makula_oem/database/type_converters/single_part_model_converter.dart';
import 'package:makula_oem/database/type_converters/statuses_model_converter.dart';
import 'package:makula_oem/database/type_converters/table_option_model_converter.dart';
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

import '../helper/model/get_inventory_part_list_response.dart';
import '../helper/model/get_list_support_accounts_response.dart';
import '../helper/model/get_own_oem_ticket_by_id_response.dart';
import '../helper/model/get_procedure_by_id_response.dart';
import '../helper/model/get_procedure_templates_response.dart';
import 'get_procedure_templates_response_dao.dart';

part 'app_database.g.dart';

@Database(version: 4, entities: [
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
  ListOwnOemSupportAccounts,
  Procedures,
  Procedure,
  GetProcedureTemplatesResponse,
  ListOwnOemProcedureTemplates,
  SignatureModel,
  ChildrenModel,
  AttachmentsModel,
  OptionsModel,
  TableOptionModel,
  ColumnsModel,
  GetProcedureByIdResponse,
  GetListSupportAccountsResponse,
  ListSupportAccounts,
  ListOwnOemInventoryPartModel,
  PartsModel,
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
  ListProceduresConverter,
  ProcedureConverter,
  ListOwnOemProcedureTemplatesModelConverter,
  ListSignatureModalConverter,
  ListChildrenModalConverter,
  ListAttachmentsModelConverter,
  ListOptionsModelConverter,
  TableOptionModelConverter,
  ListColumnsModelConverter,
  ProcedureTemplatesConverter,
  ListSupportAccountsConverter,
  ListOwnOemSupportAccountsConverter,
  ListPartModelConverter,
  SinglePartModelConverter,
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

  ProcedureTemplatesDao get procedureTemplates;

  ListOwnOemProcedureTemplatesDao get getProcedureByIdResponseDao;

  GetListSupportAccountsResponseDao get getListSupportAccountsResponseDao;

  PartModelDao get partModelDao;
}
