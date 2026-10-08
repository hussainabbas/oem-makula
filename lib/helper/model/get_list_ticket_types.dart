class GetTicketTypeList {
  List<ListTicketTypes>? listTicketTypes;

  GetTicketTypeList({this.listTicketTypes});

  GetTicketTypeList.fromJson(Map<String, dynamic> json) {
    if (json['listTicketTypes'] != null) {
      listTicketTypes = <ListTicketTypes>[];
      json['listTicketTypes'].forEach((v) {
        listTicketTypes!.add(ListTicketTypes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listTicketTypes != null) {
      data['listTicketTypes'] =
          listTicketTypes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListTicketTypes {
  String? key;
  String? value;

  ListTicketTypes({this.key, this.value});

  ListTicketTypes.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}
