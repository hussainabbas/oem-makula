import 'package:floor/floor.dart';

import '../helper/model/get_list_support_accounts_response.dart';
import '../helper/model/get_procedure_by_id_response.dart';
import '../helper/model/get_procedure_templates_response.dart';

@dao
abstract class GetListSupportAccountsResponseDao {
  @Query('SELECT * FROM GetListSupportAccountsResponse')
  Future<GetListSupportAccountsResponse?> getSupportAccount();

  @Query('DELETE FROM GetListSupportAccountsResponse')
  Future<void> deleteAllResponses();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertResponse(GetListSupportAccountsResponse response);
}
