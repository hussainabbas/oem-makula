class GetMachineFolderIdResponse {
  String? getMachineFolderId;

  GetMachineFolderIdResponse({this.getMachineFolderId});

  GetMachineFolderIdResponse.fromJson(Map<String, dynamic> json) {
    getMachineFolderId = json['getMachineFolderId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['getMachineFolderId'] = getMachineFolderId;
    return data;
  }
}