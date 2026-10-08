class ListMachines {
  String? sId;
  String? name;
  String? serialNumber;
  String? description;
  String? documentationFiles;
  String? issues;
  String? image;
  String? thumbnail;
  int? totalOpenTickets;
  String? slug;
  Customers? customer;

  ListMachines(
      {this.sId,
        this.name,
        this.serialNumber,
        this.description,
        this.documentationFiles,
        this.issues,
        this.image,
        this.thumbnail,
        this.totalOpenTickets,
        this.customer,
        this.slug});


  ListMachines.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    serialNumber = json['serialNumber'];
    description = json['description'];
    documentationFiles = json['documentationFiles'];
    issues = json['issues'];
    image = json['image'];
    thumbnail = json['thumbnail'];
    totalOpenTickets = json['totalOpenTickets'];
    slug = json['slug'];
    customer = json['customer'] != null
        ? Customers.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['serialNumber'] = serialNumber;
    data['description'] = description;
    data['documentationFiles'] = documentationFiles;
    data['issues'] = issues;
    data['image'] = image;
    data['thumbnail'] = thumbnail;
    data['totalOpenTickets'] = totalOpenTickets;
    data['slug'] = slug;
    if (customer != null) {
      data['customer'] = customer?.toJson();
    }
    return data;
  }
}

class Customers {
  String? sId;
  String? name;
  List<ListMachines>? machines;

  Customers({this.sId, this.name, this.machines});

  Customers.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    if (json['machines'] != null) {
      machines = <ListMachines>[];
      json['machines'].forEach((v) {
        machines!.add(ListMachines.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    if (machines != null) {
      data['machines'] = machines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}