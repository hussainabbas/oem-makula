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

class FinalizeOemProcedureResponse {
  String? finalizeOwnOemProcedure;

  FinalizeOemProcedureResponse({this.finalizeOwnOemProcedure});

  FinalizeOemProcedureResponse.fromJson(Map<String, dynamic> json) {
    finalizeOwnOemProcedure = json['finalizeOwnOemProcedure'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['finalizeOwnOemProcedure'] = finalizeOwnOemProcedure;
    return data;
  }
}

class DownloadProcedurePDFResponse {
  String? downloadProcedurePDF;

  DownloadProcedurePDFResponse({this.downloadProcedurePDF});

  DownloadProcedurePDFResponse.fromJson(Map<String, dynamic> json) {
    downloadProcedurePDF = json['downloadProcedurePDF'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['downloadProcedurePDF'] = downloadProcedurePDF;
    return data;
  }
}

