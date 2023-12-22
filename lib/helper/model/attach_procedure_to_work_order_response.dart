class AttachProcedureToWorkOrderResponse {
  String? attachOwnOemProcedureToWorkOrder;

  AttachProcedureToWorkOrderResponse({this.attachOwnOemProcedureToWorkOrder});

  AttachProcedureToWorkOrderResponse.fromJson(Map<String, dynamic> json) {
    attachOwnOemProcedureToWorkOrder = json['attachOwnOemProcedureToWorkOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attachOwnOemProcedureToWorkOrder'] = attachOwnOemProcedureToWorkOrder;
    return data;
  }
}
