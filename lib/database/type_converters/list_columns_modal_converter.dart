import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';

import '../../helper/utils/utils.dart';

class ListColumnsModelConverter
    extends TypeConverter<List<ColumnsModel>?, String?> {
  @override
  List<ColumnsModel>? decode(String? databaseValue) {
    console("ListColumnsModelConverter DECODE => $databaseValue");
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson.map((item) => ColumnsModel.fromJson(item)).toList();
    }
    return null;
  }

  @override
  String? encode(List<ColumnsModel>? value) {
    console("ListColumnsModelConverter encode => $value");
    if (value != null) {
      final List<dynamic> listJson =
          value.map((item) => item.toJson2()).toList();

      return json.encode(listJson);
    }
    return null;
  }
}
