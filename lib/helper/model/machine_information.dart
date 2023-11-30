
import 'package:hive/hive.dart';

part 'machine_information.g.dart';

@HiveType(typeId: 10)
class MachineInformation {
  @HiveField(0)
  String? sId;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? serialNumber;
  @HiveField(3)
  String? description;
  @HiveField(4)
  String? documentationFiles;
  @HiveField(5)
  String? issues;
  @HiveField(6)
  String? image;
  @HiveField(7)
  String? thumbnail;
  @HiveField(8)
  int? totalOpenTickets;
  @HiveField(9)
  String? slug;

  MachineInformation(
      {this.sId,
        this.name,
        this.serialNumber,
        this.description,
        this.documentationFiles,
        this.issues,
        this.image,
        this.thumbnail,
        this.totalOpenTickets,
        this.slug});

  MachineInformation.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    serialNumber = json['serialNumber'];
    description = json['description'];
    documentationFiles = json['documentationFiles'];
    issues = json['issues'];
    image = json['image'];
    thumbnail = json['thumbnail'];
    totalOpenTickets = json['totalOpenTickets'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['serialNumber'] = serialNumber;
    data['description'] = description;
    data['documentationFiles'] = documentationFiles;
    data['issues'] = issues;
    data['image'] = image;
    data['thumbnail'] = thumbnail;
    data['totalOpenTickets'] = totalOpenTickets;
    data['slug'] = slug;
    return data;
  }
}