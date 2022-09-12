class SignS3DownloadModel {
  SignS3Download? sSignS3Download;

  SignS3DownloadModel({this.sSignS3Download});

  SignS3DownloadModel.fromJson(Map<String, dynamic> json) {
    sSignS3Download = json['_signS3Download'] != null
        ? SignS3Download.fromJson(json['_signS3Download'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sSignS3Download != null) {
      data['_signS3Download'] = sSignS3Download!.toJson();
    }
    return data;
  }
}

class SignS3Download {
  String? id;
  String? signedRequest;
  String? url;

  SignS3Download({this.id, this.signedRequest, this.url});

  SignS3Download.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    signedRequest = json['signedRequest'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['signedRequest'] = signedRequest;
    data['url'] = url;
    return data;
  }
}

