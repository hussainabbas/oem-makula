import 'package:floor/floor.dart';

import '../../database/type_converters/list_part_model_converter.dart';
import '../../database/type_converters/single_part_model_converter.dart';

@entity
class GetInventoryPartListResponse {
  @primaryKey
  @TypeConverters([ListPartModelConverter])
  ListOwnOemInventoryPartModel? listOwnOemInventoryPart;

  GetInventoryPartListResponse({this.listOwnOemInventoryPart});

  GetInventoryPartListResponse.fromJson(Map<String, dynamic> json) {
    listOwnOemInventoryPart = json['listOwnOemInventoryPart'] != null
        ? ListOwnOemInventoryPartModel.fromJson(json['listOwnOemInventoryPart'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listOwnOemInventoryPart != null) {
      data['listOwnOemInventoryPart'] = listOwnOemInventoryPart!.toJson();
    }
    return data;
  }
}

@entity
class ListOwnOemInventoryPartModel {
  @primaryKey
  @TypeConverters([SinglePartModelConverter])
  List<PartsModel>? parts;

  ListOwnOemInventoryPartModel({this.parts});

  ListOwnOemInventoryPartModel.fromJson(Map<String, dynamic> json) {
    if (json['parts'] != null) {
      parts = <PartsModel>[];
      json['parts'].forEach((v) {
        parts!.add(PartsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (parts != null) {
      data['parts'] = parts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@entity
class PartsModel {
  @primaryKey
  String? sId;
  String? name;
  String? articleNumber;
  String? description;
  String? image;
  String? thumbnail;

  PartsModel(
      {this.sId,
      this.name,
      this.articleNumber,
      this.description,
      this.image,
      this.thumbnail});

  PartsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    articleNumber = json['articleNumber'];
    description = json['description'];
    image = json['image'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['articleNumber'] = articleNumber;
    data['description'] = description;
    data['image'] = image;
    data['thumbnail'] = thumbnail;
    return data;
  }
}
