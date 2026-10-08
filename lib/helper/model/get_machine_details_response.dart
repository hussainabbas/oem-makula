import 'package:makula_oem/helper/model/machine_detail_by_id.dart';

class GetMachineDetailResponse {
  GetOwnCustomerMachineById? getOwnCustomerMachineById;

  GetMachineDetailResponse({this.getOwnCustomerMachineById});

  GetMachineDetailResponse.fromJson(Map<String, dynamic> json) {
    getOwnCustomerMachineById = json['getOwnCustomerMachineById'] != null
        ? GetOwnCustomerMachineById.fromJson(json['getOwnCustomerMachineById'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (getOwnCustomerMachineById != null) {
      data['getOwnCustomerMachineById'] = getOwnCustomerMachineById!.toJson();
    }
    return data;
  }
}
