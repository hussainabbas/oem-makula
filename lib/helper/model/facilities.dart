import 'package:hive/hive.dart';

part 'facilities.g.dart';

@HiveType(typeId: 9)
class Facility {
  @HiveField(0)
  String? sId;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? urlOemFacility;
  @HiveField(3)
  int? totalMachines;
  @HiveField(4)
  int? totalOpenTickets;
  @HiveField(5)
  bool? isQRCodeEnabled;
  @HiveField(6)
  String? generalAccessUrl;

  Facility(
      {this.sId,
      this.name,
      this.urlOemFacility,
      this.totalMachines,
      this.totalOpenTickets,
      this.isQRCodeEnabled,
      this.generalAccessUrl});

  Facility.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    urlOemFacility = json['urlOemFacility'];
    totalMachines = json['totalMachines'];
    totalOpenTickets = json['totalOpenTickets'];
    isQRCodeEnabled = json['isQRCodeEnabled'];
    generalAccessUrl = json['generalAccessUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['urlOemFacility'] = urlOemFacility;
    data['totalMachines'] = totalMachines;
    data['totalOpenTickets'] = totalOpenTickets;
    data['isQRCodeEnabled'] = isQRCodeEnabled;
    data['generalAccessUrl'] = generalAccessUrl;
    return data;
  }
}
