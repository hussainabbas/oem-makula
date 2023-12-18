import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/list_assignee_response.dart';

@dao
abstract class ListAssigneeDao {
  @Query('SELECT * FROM ListAssignee LIMIT 1')
  Future<ListAssignee?> findAssignee();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertListAssignee(ListAssignee listAssignee);
}