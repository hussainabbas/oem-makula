import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:makula_oem/helper/model/chat_message_model.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/document_type.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/hive_resources.dart';
import 'package:makula_oem/helper/utils/offline_resources.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/pubnub/message_provider.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/image_full_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/image_preview_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/ticket_provider.dart';
import 'package:provider/provider.dart';
import 'package:pubnub/pubnub.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key, required String channelId, required OpenTicket ticket})
      : _ticket = ticket,
        _channelId = channelId,
        super(key: key);

  OpenTicket _ticket;
  String _channelId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  //OpenTicket _ticket = OpenTicket();
  PubnubInstance? _pubnubInstance;
  final appPreferences = AppPreferences();
  late CurrentUser userValue;
  MessageProvider? messageProvider;
  final ScrollController _scrollController = ScrollController();

  //DashboardProvider? dashboardProvider;
  final ImagePicker _picker = ImagePicker();

  _getValueFromSP() async {
    // userValue = HiveResources.currentUserBox!.get(OfflineResources.CURRENT_USER_RESPONSE)!;
    // userValue =
    //     CurrentUser.fromJson(await appPreferences.getData(AppPreferences.USER));
  }

  @override
  Widget build(BuildContext context) {
    console("ChatScreen => ${widget._channelId}");
    _getValueFromSP();
    //dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    _pubnubInstance = PubnubInstance(context);
    //_ticket = context.watch<TicketProvider>().ticketItem;
    _pubnubInstance?.setSubscriptionChannel(widget._channelId);
    messageProvider = MessageProvider(_pubnubInstance!, widget._channelId);
    return Container(
      margin: const EdgeInsets.only(top: 2),
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: containerColorUnFocused,
              padding: const EdgeInsets.all(8.0),
              child: ChangeNotifierProvider<MessageProvider>(
                  create: (context) => messageProvider!,
                  child: Consumer<MessageProvider>(
                      builder: (context, value, child) {
                    List<ChatMessage> list = [];
                    //TODO set last read time token here..
                    list.addAll(value.messages);
                    _updateTimeToken();
                    return _chatListView(list);
                  })),
            ),
          ),
          widget._ticket.status != "closed"
              ? Container(
                  color: containerColorUnFocused,
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            autocorrect: false,
                            controller: _messageController,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                                fontFamily: "Manrope",
                                fontSize: 14,
                                color: textColorLight,
                                fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontFamily: "Manrope",
                                  fontSize: 14,
                                  color: textColorLight,
                                  fontWeight: FontWeight.w500),
                              hintText: 'Write Your Message',
                              fillColor: Colors.red,
                              contentPadding: const EdgeInsets.all(18),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            _showPicker(context);
                          },
                          child: SvgPicture.asset(
                            "assets/images/attachment.svg",
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        GestureDetector(
                          onTap: () {
                            _sendMessage();
                          },
                          child: Container(
                            color: visitStatusColor,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/rectangle.svg",
                                  color: visitStatusColor,
                                ),
                                SvgPicture.asset(
                                  "assets/images/ic-send.svg",
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget _chatListView(List<ChatMessage> _messageList) {
    return _messageList.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _messageList.length,
            controller: _scrollController,
            reverse: true,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              ////print"_messageList => ${_messageList[i].message['text']}");
              return _messageBody(_messageList[i]);
            })
        : _noChat();
  }

  _updateTimeToken() async {
    List<MembershipMetadataInput> channelMetaDataList = [];
    channelMetaDataList.add(MembershipMetadataInput(widget._channelId, custom: {
      "lastReadTimetoken": "${Timetoken.fromDateTime(DateTime.now())}"
    }));
    await _pubnubInstance?.setMemberships(channelMetaDataList);
  }

  Widget _messageBody(ChatMessage message) {
    return message.uuid == userValue?.chatUUID.toString()
        ? _sender(message)
        : _receiver(message);
  }

  Widget _sender(ChatMessage message) {
    var provider = context.read<TicketProvider>().ticketItem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(
          height: 8,
        ),
        Container(
          padding: const EdgeInsets.all(0),
          child: ChatBubble(
              clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
              alignment: Alignment.topRight,
              elevation: 0,
              backGroundColor: provider.status == "closed"
                  ? chatBubbleSenderClosed
                  : chatBubbleSenderOpen,
              child: message.messageType == MessageType.normal
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6,
                      ),
                      child: Text(
                        parseHtmlString(
                                message.message['text'].toString().trim())
                            .toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    )
                  : isFileImage(message.message['file']['name'])
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: GestureDetector(
                            onTap: () {
                              _fullViewImageView(message.fileURL);
                            },
                            child: Center(
                              child: Hero(
                                tag: setAuthOnFile(
                                    userValue?.chatUUID.toString() ?? "",
                                    userValue?.chatToken.toString() ?? "",
                                    message.fileURL),
                                transitionOnUserGestures: true,
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => const Padding(
                                    padding: EdgeInsets.zero,
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                  imageUrl: setAuthOnFile(
                                      userValue?.chatUUID.toString() ?? "",
                                      userValue?.chatToken.toString() ?? "",
                                      message.fileURL),
                                ),
                              ),
                            ),
                          ),
                        )
                      : _documentWidget(message)),
        ),
        const SizedBox(
          height: 4,
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: RichText(
              text: TextSpan(style: TextStyle(color: textColorDark), children: [
            TextSpan(
              text: message.userName.isNotEmpty
                  ? message.userName.toString()
                  : userValue.name.toString(),
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Manrope',
              ),
            ),
            TextSpan(
              text: ", ${getFormattedDate(message.timeToken, formatDateHHMMA)}",
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Manrope',
              ),
            ),
          ])),
        ),
      ],
    );
  }

  Widget _receiver(ChatMessage message) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/picture_circle.svg",
                  color: textColorDark,
                ),
                Text(
                  getInitials(message.userName.isNotEmpty
                          ? message.userName.toString()
                          : userValue.name.toString())
                      .toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                      fontFamily: 'Manrope'),
                )
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: ChatBubble(
                      clipper:
                          ChatBubbleClipper1(type: BubbleType.receiverBubble),
                      backGroundColor: Colors.white,
                      elevation: 0,
                      child: message.messageType == MessageType.normal
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6,
                              ),
                              child: Text(
                                parseHtmlString(message.message['text']
                                        .toString()
                                        .trim())
                                    .toString(),
                                style: const TextStyle(color: Colors.black),
                              ),
                            )
                          : isFileImage(message.message['file']['name'])
                              ? SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: GestureDetector(
                                    onTap: () {
                                      _fullViewImageView(message.fileURL);
                                    },
                                    child: Center(
                                      child: Hero(
                                        tag: setAuthOnFile(
                                            userValue.chatUUID.toString(),
                                            userValue.chatToken.toString(),
                                            message.fileURL),
                                        transitionOnUserGestures: true,
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              const Padding(
                                            padding: EdgeInsets.zero,
                                            child: CircularProgressIndicator
                                                .adaptive(),
                                          ),
                                          imageUrl: setAuthOnFile(
                                              userValue.chatUUID.toString(),
                                              userValue.chatToken.toString(),
                                              message.fileURL),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : _documentWidget(message),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(color: textColorDark),
                            children: [
                          TextSpan(
                            text: message.userName.isNotEmpty
                                ? message.userName.toString()
                                : userValue.name.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          TextSpan(
                            text:
                                ", ${getFormattedDate(message.timeToken, formatDateHHMMA)}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ])),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _documentWidget(ChatMessage message) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: GestureDetector(
        onTap: () {
          _launchURL(setAuthOnFile(userValue.chatUUID.toString(),
              userValue.chatToken.toString(), message.fileURL));
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.insert_drive_file,
                    size: 32,
                  ),
                  Text(
                    "Click to view",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              message.message['file']['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget _noChat() {
    return messageProvider!.isChatLoading
        ? const Center(child: CircularProgressIndicator.adaptive())
        : noMachineWidget(context, "No Chat found");
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      showLoaderDialog(context, "Please wait...");
      await messageProvider!
          .sendMessage(widget._channelId, _messageController.text.toString());
      Navigator.pop(context);
      _messageController.text = "";
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      pickImageFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    pickImageFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_call),
                  title: const Text('Video'),
                  onTap: () {
                    pickVideoFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.document_scanner),
                  title: const Text('Document'),
                  onTap: () {
                    pickDocument();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      if (getFileSize(file) > 100) {
        context.showErrorSnackBar("Maximum file size limit 100 MB.");
        return;
      }
      String fileName = file.path.split('/').last;
      _sendImage(file.readAsBytesSync(), fileName,
          getFileSizeInBytes(file).toString());
    } else {
      // User canceled the picker
    }
  }

  Future pickImageFromGallery() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    File imageFile = File(image!.path);
    if (getFileSize(imageFile) > 100) {
      context.showErrorSnackBar("Maximum file size limit 100 MB.");
      return;
    }
    String fileName = imageFile.path.split('/').last;
    List<int> imageBytes = imageFile.readAsBytesSync();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(
            image: imageBytes,
            fileName: fileName,
            file: imageFile,
            messageProvider: messageProvider,
            documentType: DocumentType.image,
            channelId: widget._channelId,
            fileSize: getFileSizeInBytes(imageFile).toString()),
      ),
    );
    // _sendImage(imageBytes, fileName, getFileSizeInBytes(imageFile).toString());
  }

  Future pickImageFromCamera() async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    File imageFile = File(image!.path);
    if (getFileSize(imageFile) > 100) {
      context.showErrorSnackBar("Maximum file size limit 100 MB.");
      return;
    }
    String fileName = imageFile.path.split('/').last;
    List<int> imageBytes = imageFile.readAsBytesSync();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(
            image: imageBytes,
            fileName: fileName,
            file: imageFile,
            documentType: DocumentType.image,
            messageProvider: messageProvider,
            channelId: widget._channelId,
            fileSize: getFileSizeInBytes(imageFile).toString()),
      ),
    );
    //_sendImage(imageBytes, fileName, getFileSizeInBytes(imageFile).toString());
  }

  Future pickVideoFromCamera() async {
    XFile? image = await _picker.pickVideo(source: ImageSource.camera);
    File imageFile = File(image!.path);
    if (getFileSize(imageFile) > 100) {
      context.showErrorSnackBar("Maximum video size limit 100 MB.");
      return;
    }
    String fileName = imageFile.path.split('/').last;
    List<int> imageBytes = imageFile.readAsBytesSync();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(
            image: imageBytes,
            fileName: fileName,
            file: imageFile,
            messageProvider: messageProvider,
            documentType: DocumentType.video,
            channelId: widget._channelId,
            fileSize: getFileSizeInBytes(imageFile).toString()),
      ),
    );
    //_sendImage(imageBytes, fileName, getFileSizeInBytes(imageFile).toString());
  }

  void _sendImage(List<int> image, String fileName, String fileSize) async {
    console("_sendImage => ${widget._channelId} , $fileName");
    await messageProvider!.sendDocument(widget._channelId, image, fileName,
        fileSize, getFileExtension(fileName));
  }

  _fullViewImageView(String imageUrl) {
    var url = setAuthOnFile(userValue.chatUUID.toString(),
        userValue.chatToken.toString(), imageUrl);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ImageViewFullScreen(
        imageURL: url,
      ),
    ));
  }

  @override
  void dispose() {
    messageProvider?.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
