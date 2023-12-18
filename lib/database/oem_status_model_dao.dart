import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';

@dao
abstract class OemStatusDao {
  @Query('SELECT * FROM OemStatus')
  Future<List<OemStatus>> findAllOemStatuses();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertOemStatus(OemStatus entity);
}
