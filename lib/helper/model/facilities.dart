
import 'package:floor/floor.dart';

@entity
class Facility {
  @primaryKey
  String? sId;
  String? name;
  String? urlOemFacility;
  int? totalMachines;
  int? totalOpenTickets;
  String? generalAccessUrl;

  Facility(
      {this.sId,
      this.name,
      this.urlOemFacility,
      this.totalMachines,
      this.totalOpenTickets,
      this.generalAccessUrl});

  Facility.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    urlOemFacility = json['urlOemFacility'];
    totalMachines = json['totalMachines'];
    totalOpenTickets = json['totalOpenTickets'];
    generalAccessUrl = json['generalAccessUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['urlOemFacility'] = urlOemFacility;
    data['totalMachines'] = totalMachines;
    data['totalOpenTickets'] = totalOpenTickets;
    data['generalAccessUrl'] = generalAccessUrl;
    return data;
  }
}
