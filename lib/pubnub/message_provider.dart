import 'package:flutter/cupertino.dart';
import 'package:makula_oem/helper/model/chat_message_model.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:pubnub/pubnub.dart';

class MessageProvider with ChangeNotifier {
  final PubNub pubnub;
  final Subscription subscription;
  late List<ChatMessage> _messages;
  String _channel = "";
  bool isChatLoading = true;

  List<ChatMessage> get messages =>
      ([..._messages]..sort((m1, m2) => m2.timeToken.compareTo(m1.timeToken)))
          .toList();

  MessageProvider._(this.pubnub, this.subscription, this._channel) {
    _messages = [];
    subscription.messages.listen((m) {
      //print("New Message => ${m.content}");
      getMessagesCount(_channel, DateTime.now().millisecondsSinceEpoch);
      if (m.messageType == MessageType.normal) {
        _getUserDetail(m, "");
      }
      if (m.messageType == MessageType.file) {
        var fileInfo = m.payload['file'];
        var id = fileInfo['id']; // unique file id
        var name = fileInfo['name']; // file name

        var fileURL = pubnub.files.getFileUrl(_channel, id, name);
        _getUserDetail(m, fileURL.toString());
      }
    });
    _addHistoryMessages(_channel);
  }

  MessageProvider(PubnubInstance pn, String channel)
      : this._(pn.instance, pn.subscription, channel);

  _getUserDetail(Envelope m, String fileURL) async {
    GetUuidMetadataResult result =
        await pubnub.objects.getUUIDMetadata(uuid: m.uuid.value);
    String? name = result.metadata?.name;
    _addMessage(ChatMessage(
        messageType: m.messageType,
        timeToken: '${m.publishedAt}',
        channel: m.channel,
        uuid: m.uuid.value,
        fileURL: fileURL,
        userName: name.toString(),
        message: m.content));
  }

  _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  _addHistoryMessages(String channel) async {
    try {
      _messages.clear();
      BatchHistoryResult result = await pubnub.batch
          .fetchMessages({channel}, count: 100, includeUUID: true);
      List<BatchHistoryResultEntry> resultList = result.channels[channel] ?? [];
      getMessagesCount(channel, DateTime.now().millisecondsSinceEpoch);
      var allUUIDMetaData = await pubnub.objects.getAllUUIDMetadata();
      var userName = "";
      for (var batch in resultList) {
        for (var userDetail in allUUIDMetaData.metadataList!) {
          if (userDetail.id == batch.uuid) {
            userName = userDetail.name.toString();
            break;
          }
        }
        if (batch.messageType == MessageType.normal) {
          _addHistoryMessageInChat(batch, "", userName);
        } else if (batch.messageType == MessageType.file) {
          var fileInfo = batch.message['file'];
          var id = fileInfo['id']; // unique file id
          var fileName = fileInfo['name'];

          var fileURL = pubnub.files.getFileUrl(_channel, id, fileName);
          _addHistoryMessageInChat(batch, fileURL.toString(), userName);
        } else {}
      }
      isChatLoading = false;
      notifyListeners();
    } catch (e) {
      isChatLoading = false;
      notifyListeners();
    }
  }

  _addHistoryMessageInChat(
      BatchHistoryResultEntry batch, String fileUrl, String userName) {
    _messages.add(ChatMessage(
        timeToken: '${batch.timetoken}',
        channel: _channel,
        uuid: batch.uuid ?? "",
        fileURL: fileUrl,
        messageType: batch.messageType,
        userName: userName,
        message: batch.message));
  }

  sendMessage(String channel, String message) async {
    await pubnub.publish(
        channel,
        {'text': message},
        storeMessage: true,
        ttl: 0,
    );
  }

  sendDocument(String channel, List<int> file, String fileName , String fileSize, String fileType) async {
    await pubnub.files.sendFile(
      channel,
      "${DateTime.now().millisecond}_$fileName",
      file,
      storeFileMessage: true,
      fileMessage: {
        "text": fileName,
        "type": fileType,
        "size": fileSize
      });
  }

  getMessagesCount(String channel, int timeMillis) async {
    await pubnub.batch.countMessages({channel},
        timetoken: Timetoken(BigInt.from(timeMillis * 10000)));
  }

  @override
  void dispose() async {
    subscription.cancel();
    await pubnub.announceLeave(channels: {_channel});
    super.dispose();
  }
}
