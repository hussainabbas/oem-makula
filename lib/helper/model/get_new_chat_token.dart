class NewChatToken {
  String? getNewChatToken;
  NewChatToken({this.getNewChatToken});

  NewChatToken.fromJson(Map<dynamic, dynamic> json) {
    getNewChatToken = json['getNewChatToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['getNewChatToken'] = getNewChatToken;
    return data;
  }
}