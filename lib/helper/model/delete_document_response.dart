class DeleteDocumentResponse {
  String? deleteOwnOemSubmissionById;

  DeleteDocumentResponse({this.deleteOwnOemSubmissionById});

  DeleteDocumentResponse.fromJson(Map<String, dynamic> json) {
    deleteOwnOemSubmissionById = json['deleteOwnOemSubmissionById'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deleteOwnOemSubmissionById'] = deleteOwnOemSubmissionById;
    return data;
  }
}