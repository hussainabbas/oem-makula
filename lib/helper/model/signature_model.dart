class SignatureRequestModel {
  String? id;
  String? date;
  String? name;
  String? signature;

  SignatureRequestModel({
    this.id,
    this.name,
    this.date,
    this.signature,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': id,
      'date': date,
      'name': name,
      'signatureUrl': signature,
    };
    return data;
  }
}
