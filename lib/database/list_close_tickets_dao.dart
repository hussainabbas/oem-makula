import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/list_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_open_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_open_tickets_model.dart';

@dao
abstract class ListCloseTicketsDao {
  @Query('SELECT * FROM ListCloseTickets')
  Future<List<ListCloseTickets>?> getListCloseTickets();

  @insert
  Future<void> insertListCloseTickets(ListCloseTickets data);

  @update
  Future<void> updateListCloseTickets(ListCloseTickets data);

  @delete
  Future<void> deleteListCloseTickets(ListCloseTickets data);


  @Query('DELETE FROM ListCloseTickets')
  Future<void> deleteAllRecords();
}