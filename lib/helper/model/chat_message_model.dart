import 'package:pubnub/pubnub.dart';

class ChatMessage {
  final String timeToken;
  final String channel;
  final String uuid;
  final Map message;
  final String fileURL;
  final String userName;
  final MessageType messageType;

  ChatMessage(
      {required this.timeToken,
      required this.channel,
      required this.uuid,
      required this.fileURL,
      required this.userName,
      required this.messageType,
      required this.message});

  factory ChatMessage.fromJson(Map json) => ChatMessage(
      timeToken: json['timeToken'],
      channel: json['channel'],
      uuid: json['uuid'],
      fileURL: '',
      messageType: json['messageType'],
      userName: '',
      message: json['message']);
}
