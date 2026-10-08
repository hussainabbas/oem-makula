import 'package:flutter/cupertino.dart';

class DashboardProvider with ChangeNotifier {
  String _chatToken = "";
  String _subscribeKey = "";
  String _publishKey = "";
  String _uuid = "";
  String _channelId = "";

  String get chatToken => _chatToken;

  String get subscribeKey => _subscribeKey;

  String get publishKey => _publishKey;

  String get uuid => _uuid;

  String get channelId => _channelId;

  void setChatDetails(
      String chatToken, String subscribeKey, String publishKey, String uuid) {
    _chatToken = chatToken;
    _subscribeKey = subscribeKey;
    _publishKey = publishKey;
    _uuid = uuid;
    notifyListeners();
  }

  void setChannelId(String channel) {
    _channelId = channel;
    notifyListeners();
  }

  void clearChannelId(String channel) {
    _channelId = channel;
  }
}
