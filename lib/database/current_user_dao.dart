import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';

@dao
abstract class CurrentUserDao {
  @Query('SELECT * FROM CurrentUser LIMIT 1')
  Future<CurrentUser?> getCurrentUserDetailsFromDb();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertCurrentUserDetailsIntoDb(CurrentUser data);

  @delete
  Future<void> deleteCurrentUserResponse(CurrentUser data);

}