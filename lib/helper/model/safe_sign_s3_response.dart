class SafeSigns3Response {
  SafeSignS3? sSafeSignS3;

  SafeSigns3Response({this.sSafeSignS3});

  SafeSigns3Response.fromJson(Map<String, dynamic> json) {
    sSafeSignS3 = json['_safeSignS3'] != null
        ? new SafeSignS3.fromJson(json['_safeSignS3'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sSafeSignS3 != null) {
      data['_safeSignS3'] = this.sSafeSignS3!.toJson();
    }
    return data;
  }
}

class SafeSignS3 {
  String? id;
  String? signedRequest;
  String? url;

  SafeSignS3({this.id, this.signedRequest, this.url});

  SafeSignS3.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    signedRequest = json['signedRequest'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['signedRequest'] = this.signedRequest;
    data['url'] = this.url;
    return data;
  }
}



class ImageRequestModel {
  String? name;
  int? size;
  String? type;
  String? url;

  ImageRequestModel({this.name, this.size, this.url, this.type});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'size': size,
      'type': type,
      'url': url,
    };
    return data;
  }
}