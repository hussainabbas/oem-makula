import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';

class GetProcedureByIdResponse {
  ListOwnOemProcedureTemplates? getOwnOemProcedureById;

  GetProcedureByIdResponse({this.getOwnOemProcedureById});

  GetProcedureByIdResponse.fromJson(Map<String, dynamic> json) {
    getOwnOemProcedureById = json['getOwnOemProcedureById'] != null
        ? ListOwnOemProcedureTemplates.fromJson(json['getOwnOemProcedureById'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (getOwnOemProcedureById != null) {
      data['getOwnOemProcedureById'] = getOwnOemProcedureById!.toJson();
    }
    return data;
  }
}
