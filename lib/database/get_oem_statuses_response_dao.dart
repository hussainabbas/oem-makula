import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';

@dao
abstract class GetOemStatusesResponseDao {
  @Query('SELECT * FROM StatusData')
  Future<List<StatusData>> findAllGetOemStatusesResponses();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertGetOemStatusesResponse(StatusData entity);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateGetOemStatusesResponse(StatusData entity);

  @Query('DELETE FROM StatusData')
  Future<void> deleteAllRecords();
}