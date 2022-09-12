class Oem {
  String? sId;
  String? name;
  String? logo;
  String? thumbnail;
  String? backgroundColor;
  String? textColor;
  String? urlOem;
  String? slug;
  String? urlOemFacility;

  Oem(
      {sId,
        name,
        logo,
        thumbnail,
        backgroundColor,
        textColor,
        urlOem,
        slug,
        urlOemFacility});

  Oem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    logo = json['logo'];
    thumbnail = json['thumbnail'];
    backgroundColor = json['backgroundColor'];
    textColor = json['textColor'];
    urlOem = json['urlOem'];
    slug = json['slug'];
    urlOemFacility = json['urlOemFacility'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['logo'] = logo;
    data['thumbnail'] = thumbnail;
    data['backgroundColor'] = backgroundColor;
    data['textColor'] = textColor;
    data['urlOem'] = urlOem;
    data['slug'] = slug;
    data['urlOemFacility'] = urlOemFacility;
    return data;
  }
}