import 'package:floor/floor.dart';

@entity
class MachineInformation {
  @primaryKey
  String? sId;
  String? name;
  String? serialNumber;
  String? description;
  String? documentationFiles;
  String? issues;
  String? image;
  String? thumbnail;
  int? totalOpenTickets;
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
