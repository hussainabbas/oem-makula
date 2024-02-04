import 'package:floor/floor.dart';

import '../helper/model/get_inventory_part_list_response.dart';

@dao
abstract class PartModelDao {
  @Query('SELECT * FROM ListOwnOemInventoryPartModel')
  Future<ListOwnOemInventoryPartModel?> getInventoryPartModel();

  @Query('DELETE FROM ListOwnOemInventoryPartModel')
  Future<void> deleteAllInventoryPartModels();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertInventoryPartModel(
      ListOwnOemInventoryPartModel inventoryPartModel);
}
