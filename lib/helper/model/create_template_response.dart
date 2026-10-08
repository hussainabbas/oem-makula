class CreateTemplateResponse {
  String? getOwnOemFormUrlByTemplateId;

  CreateTemplateResponse({this.getOwnOemFormUrlByTemplateId});

  CreateTemplateResponse.fromJson(Map<String, dynamic> json) {
    getOwnOemFormUrlByTemplateId = json['getOwnOemFormUrlByTemplateId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['getOwnOemFormUrlByTemplateId'] = this.getOwnOemFormUrlByTemplateId;
    return data;
  }
}