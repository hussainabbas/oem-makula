import 'package:makula_oem/helper/model/oem.dart';

class Customers {
  String? sId;
  String? name;
  Oem? oem;

  Customers({this.sId, this.name, this.oem});

  Customers.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    oem = json['oem'] != null ? Oem.fromJson(json['oem']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    if (oem != null) {
      data['oem'] = oem!.toJson();
    }
    return data;
  }
}
