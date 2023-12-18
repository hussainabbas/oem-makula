import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/login_mobile_oem_response.dart';

@dao
abstract class LoginMobileDao {
  @Query('SELECT * FROM LoginMobile LIMIT 1')
  Future<LoginMobile?> getLoginResponseFromDb();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertLoginMobileOemIntoDb(LoginMobile loginMobileOem);

  @delete
  Future<void> deleteLoginMobileOem(LoginMobile loginMobileOem);
}
