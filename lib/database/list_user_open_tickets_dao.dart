import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/list_user_open_tickets_model.dart';

@dao
abstract class ListUserOpenTicketsDao {
  @Query('SELECT * FROM ListUserOpenTickets')
  Future<List<ListUserOpenTickets>?> getListUserOpenTickets();

  @insert
  Future<void> insertListUserOpenTickets(ListUserOpenTickets listUserOpenTickets);

  @update
  Future<void> updateListUserOpenTickets(ListUserOpenTickets listUserOpenTickets);

  @delete
  Future<void> deleteListUserOpenTickets(ListUserOpenTickets listUserOpenTickets);
}