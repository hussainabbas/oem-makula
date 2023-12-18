import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/list_open_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_open_tickets_model.dart';

@dao
abstract class ListOpenTicketsDao {
  @Query('SELECT * FROM ListOpenTickets')
  Future<List<ListOpenTickets>?> getListOpenTickets();

  @insert
  Future<void> insertListOpenTickets(ListOpenTickets listOpenTickets);

  @update
  Future<void> updateListOpenTickets(ListOpenTickets listOpenTickets);

  @delete
  Future<void> deleteListOpenTickets(ListOpenTickets listOpenTickets);
}