import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/list_user_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_open_tickets_model.dart';

@dao
abstract class ListUserCloseTicketsDao {
  @Query('SELECT * FROM ListUserCloseTickets')
  Future<List<ListUserCloseTickets>?> getListUserCloseTickets();

  @insert
  Future<void> insertListUserCloseTickets(ListUserCloseTickets listUserOpenTickets);

  @update
  Future<void> updateListUserCloseTickets(ListUserCloseTickets listUserOpenTickets);

  @delete
  Future<void> deleteListUserCloseTickets(ListUserCloseTickets listUserOpenTickets);
}