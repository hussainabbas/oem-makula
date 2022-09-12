class ChatKeys {
  String? subscribeKey;
  String? publishKey;

  ChatKeys({this.subscribeKey, this.publishKey});

  ChatKeys.fromJson(Map<dynamic, dynamic> json) {
    subscribeKey = json['subscribeKey'];
    publishKey = json['publishKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subscribeKey'] = subscribeKey;
    data['publishKey'] = publishKey;
    return data;
  }
}
