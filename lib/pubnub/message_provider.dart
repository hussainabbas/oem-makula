import 'package:flutter/cupertino.dart';
import 'package:makula_oem/helper/model/chat_message_model.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:pubnub/pubnub.dart';

class MessageProvider with ChangeNotifier {
  final PubNub pubnub;
  final Subscription subscription;
  late List<ChatMessage> _messages;
  String _channel = "";
  bool isChatLoading = true;
  bool downloadProcedurePDFLoading = true;
  bool showFinalizeProcedureLoading = true;
  bool attachProcedureLoading = true;
  Map<String, dynamic> downloadProcedureData = {};

  List<ChatMessage> get messages =>
      ([..._messages]..sort((m1, m2) => m2.timeToken.compareTo(m1.timeToken)))
          .toList();

  MessageProvider._(this.pubnub, this.subscription, this._channel) {
    _messages = [];

    subscription.messages.listen((m) async {
      if (m.content["text"] == "finalizeOwnOemProcedure") {
        showFinalizeProcedureLoading = false;
        notifyListeners();

        showFinalizeProcedureLoading = true;
      }
      else if (m.content["text"] == "attachOwnOemProcedureToWorkOrder") {
        attachProcedureLoading = false;
        notifyListeners();

        attachProcedureLoading = true;
      }
      else if (m.content["text"] == "downloadProcedurePDF") {
        console("New Message => ${m.content["text"]}");
        downloadProcedureData = m.content;
        var content = m.content;
        var payload = content["payload"];
        var url = payload["url"];
        downloadProcedurePDFLoading = false;
        // newLaunchURL(url.toString().replaceAll(" ", "%20"));
        notifyListeners();

        downloadProcedurePDFLoading = true;
      }
      else {
        // console("New Message => ${m.content}");
        // getMessagesCount(_channel, DateTime
        //     .now()
        //     .millisecondsSinceEpoch);
        // if (m.messageType == MessageType.normal) {
        //   _getUserDetail(m, "");
        //   notifyListeners();
        // }
        // if (m.messageType == MessageType.file) {
        //   var fileInfo = m.payload['file'];
        //   var id = fileInfo['id']; // unique file id
        //   var name = fileInfo['name']; // file name
        //
        //   var fileURL = pubnub.files.getFileUrl(_channel, id, name);
        //   _getUserDetail(m, fileURL.toString());
        //   notifyListeners();
        // }
      }
      console("New Message ABCC => ${m.content}");
      attachProcedureLoading = false;
      showFinalizeProcedureLoading = false;
      notifyListeners();
      getMessagesCount(_channel, DateTime
          .now()
          .millisecondsSinceEpoch);
      if (m.messageType == MessageType.normal) {

        _getUserDetail(m, "");
        notifyListeners();
      }
      if (m.messageType == MessageType.file) {
        var fileInfo = m.payload['file'];
        var id = fileInfo['id']; // unique file id
        var name = fileInfo['name']; // file name

        var fileURL = pubnub.files.getFileUrl(_channel, id, name);
        _getUserDetail(m, fileURL.toString());
        notifyListeners();
      }
    });
    _addHistoryMessages(_channel);
  }

  MessageProvider(PubnubInstance pn, String channel)
      : this._(pn.instance, pn.subscription, channel);

  _getUserDetail(Envelope m, String fileURL) async {
    try {
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
    } catch (e) {

    }
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

  _checkProcedurePDFDownload(String channel) async {
    console("checkProcedurePDFDownload channel => $channel");
    try {
      var result = await pubnub.batch
          .fetchMessages({channel}, count: 100, includeUUID: true);
      List<BatchHistoryResultEntry> resultList = result.channels[channel] ?? [];

      for (var batch in resultList) {
         console("checkProcedurePDFDownload message => ${batch.message}");
         console("checkProcedurePDFDownload uuid => ${batch.uuid}");
         console("checkProcedurePDFDownload error => ${batch.error?.message}");
      }
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  @override
  void dispose() async {
    subscription.cancel();
    await pubnub.announceLeave(channels: {_channel});
    super.dispose();
  }
}
