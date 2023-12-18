import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';

@dao
abstract class StatusesDao {
  @Query('SELECT * FROM Statuses')
  Future<List<Statuses>> findAllStatuses();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertStatus(Statuses entity);
}
