import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';

class ListSignatureModalConverter
    extends TypeConverter<List<SignatureModel>?, String?> {
  @override
  List<SignatureModel>? decode(String? databaseValue) {
    if (databaseValue != null) {
      final List<dynamic> listJson = json.decode(databaseValue);
      return listJson.map((item) => SignatureModel.fromJson(item)).toList();
    }
    return null;
  }

  @override
  String? encode(List<SignatureModel>? value) {
    if (value != null) {
      final List<dynamic> listJson =
          value.map((item) => item.toJson()).toList();
      return json.encode(listJson);
    }
    return null;
  }
}
