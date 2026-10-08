class DetachProcedureResponse {
  DetachOwnOemProcedureFromWorkOrder? detachOwnOemProcedureFromWorkOrder;

  DetachProcedureResponse({this.detachOwnOemProcedureFromWorkOrder});

  DetachProcedureResponse.fromJson(Map<String, dynamic> json) {
    detachOwnOemProcedureFromWorkOrder =
    json['detachOwnOemProcedureFromWorkOrder'] != null
        ? new DetachOwnOemProcedureFromWorkOrder.fromJson(
        json['detachOwnOemProcedureFromWorkOrder'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.detachOwnOemProcedureFromWorkOrder != null) {
      data['detachOwnOemProcedureFromWorkOrder'] =
          this.detachOwnOemProcedureFromWorkOrder!.toJson();
    }
    return data;
  }
}

class DetachOwnOemProcedureFromWorkOrder {
  String? sId;

  DetachOwnOemProcedureFromWorkOrder({this.sId});

  DetachOwnOemProcedureFromWorkOrder.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    return data;
  }
}