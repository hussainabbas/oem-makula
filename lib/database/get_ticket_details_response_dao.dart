import 'package:floor/floor.dart';

import '../helper/model/get_own_oem_ticket_by_id_response.dart';

@dao
abstract class GetTicketDetailResponseDao {
  @Query('SELECT * FROM GetOwnOemTicketById WHERE sId = :id')
  Future<GetOwnOemTicketById?> getTicketDetailResponseById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertOrUpdateTicketDetailResponse(GetOwnOemTicketById ticketDetailResponse);
}