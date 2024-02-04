import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';

import '../helper/model/get_procedure_templates_response.dart';

@dao
abstract class ProcedureTemplatesDao {
  @Query('SELECT * FROM GetProcedureTemplatesResponse')
  Future<List<GetProcedureTemplatesResponse>> getAllProcedureTemplates();

  @Query('SELECT * FROM GetProcedureTemplatesResponse LIMIT 1')
  Future<GetProcedureTemplatesResponse?> getProcedureTemplates();

  @Insert()
  Future<void> insertOrUpdate(GetProcedureTemplatesResponse response);

  @Query('DELETE FROM GetProcedureTemplatesResponse')
  Future<void> deleteAllRecords();

}