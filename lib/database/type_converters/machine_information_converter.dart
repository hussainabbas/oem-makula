import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:makula_oem/helper/model/machine_information.dart';

class MachineInformationConverter
    extends TypeConverter<MachineInformation?, String?> {
  @override
  MachineInformation? decode(String? databaseValue) {
    if (databaseValue != null) {
      final Map<String, dynamic> map = json.decode(databaseValue);
      return MachineInformation.fromJson(map);
    }
    return null;
  }

  @override
  String? encode(MachineInformation? value) {
    if (value != null) {
      return json.encode(value.toJson());
    }
    return null;
  }
}
