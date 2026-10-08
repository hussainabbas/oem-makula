import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/document_type.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/pubnub/message_provider.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:video_player/video_player.dart';

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({super.key,
    required var image,
    required String fileName,
    required String channelId,
    required File file,
    required DocumentType documentType,
    required MessageProvider? messageProvider,
    required String fileSize})
      : _image = image,
        _fileName = fileName,
        _fileSize = fileSize,
        _documentType = documentType,
        _channelId = channelId,
        _file = file,
        _messageProvider = messageProvider;

  final _image;
  final String _fileName;
  final String _fileSize;
  final File _file;
  final String _channelId;
  final DocumentType _documentType;
  final MessageProvider? _messageProvider;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    if (widget._documentType == DocumentType.video) {
      _videoPlayerController = VideoPlayerController.file(widget._file)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController.play();
        });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget._documentType == DocumentType.video) {
      _videoPlayerController.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _imagePreviewBody(),
    );
  }



  Widget _imagePreviewBody() {
    return Column(
      children: [
        Expanded(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                _checkDocumentType(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 32, 8, 8),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            )),
        Container(
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
                  child: TextView(
                      text: widget._fileName,
                      textColor: textColorLight,
                      textFontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
                const SizedBox(
                  width: 8,
                ),
                GestureDetector(
                  onTap: () {
                    _sendImage();
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
      ],
    );
  }

  Widget _checkDocumentType() {
    if (widget._documentType == DocumentType.image) {
      return _imageViewer();
    } else if (widget._documentType == DocumentType.video) {
      return _videoViewer();
    } else {
      return _imageViewer();
    }
  }

  Widget _imageViewer() {
    return Image.memory(
      widget._image,
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height,
      fit: BoxFit.contain,
    );
  }

  Widget _videoViewer() {
    return Container(
      color: Colors.black,
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height,
      child: AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            VideoPlayer(_videoPlayerController),
            VideoProgressIndicator(
                _videoPlayerController, allowScrubbing: true),
          ],
        ),
      ),
    );
  }

  void _sendImage() async {
    console("_sendImage => ${widget._channelId} , ${widget._file.exists().toString()}");
    context.showCustomDialog();
    await widget._messageProvider!.sendDocument(
        widget._channelId,
        widget._image,
        widget._fileName,
        widget._fileSize,
        getFileExtension(widget._fileName));
    Navigator.pop(context);
    Timer(const Duration(seconds: 1), () => {Navigator.pop(context)});
  }

}
