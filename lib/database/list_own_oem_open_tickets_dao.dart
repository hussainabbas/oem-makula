import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';

@dao
abstract class ListOwnOemOpenTicketsDao {
  @Query('SELECT * FROM ListOwnOemOpenTickets')
  Future<List<ListOwnOemOpenTickets>> findAllListOwnOemOpenTickets();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertListOwnOemOpenTickets(ListOwnOemOpenTickets entity);
}
