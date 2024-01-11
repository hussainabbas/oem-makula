import 'dart:convert';

import 'package:floor/floor.dart';

import '../../helper/model/get_procedure_templates_response.dart';

class TableOptionModelConverter
    extends TypeConverter<TableOptionModel?, String?> {
  @override
  TableOptionModel? decode(String? databaseValue) {
    if (databaseValue != null) {
      final Map<String, dynamic> map = json.decode(databaseValue);
      return TableOptionModel.fromJson(map);
    }
    return null;
  }

  @override
  String? encode(TableOptionModel? value) {
    if (value != null) {
      return json.encode(value.toJson());
    }
    return null;
  }
}
