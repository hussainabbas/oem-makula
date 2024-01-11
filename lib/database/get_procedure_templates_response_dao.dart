import 'package:floor/floor.dart';

import '../helper/model/get_procedure_by_id_response.dart';
import '../helper/model/get_procedure_templates_response.dart';

@dao
abstract class ListOwnOemProcedureTemplatesDao {
  @Query('SELECT * FROM ListOwnOemProcedureTemplates WHERE sId = :id')
  Future<ListOwnOemProcedureTemplates?> getProcedureById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertListOwnOemProcedureTemplatesById(ListOwnOemProcedureTemplates template);
}
