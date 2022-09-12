import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/get_document_by_id_response.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/documents/document_view_model.dart';
import 'package:makula_oem/views/widgets/makula_app_bar_gray.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyDocumentViewerScreen extends StatefulWidget {
  const MyDocumentViewerScreen(
      {Key? key,
      required String webUrl,
      required String templateName,
      required String documentId})
      : _webUrl = webUrl,
        _templateName = templateName,
        _documentId = documentId,
        super(key: key);

  final String _webUrl;
  final String _templateName;
  final String _documentId;

  @override
  State<MyDocumentViewerScreen> createState() => _MyDocumentViewerScreenState();
}

class _MyDocumentViewerScreenState extends State<MyDocumentViewerScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  GetDocumentByIdResponse _documentByIdResponse = GetDocumentByIdResponse();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: _getDocumentDetails(),
          builder: (context, projectSnap) {
            if (projectSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (projectSnap.hasError) {
              console(projectSnap.error.toString());
              return const Center(child: Text(unexpectedError));
            } else {
              return Column(
                children: [
                  AppBarCustom(
                    title: widget._templateName,
                  ),
                  Expanded(
                    child: WebView(
                      initialUrl: _documentByIdResponse
                          .getOwnOemSubmissionById?.downloadUrl,
                      allowsInlineMediaPlayback: true,
                      javascriptMode: JavascriptMode.unrestricted,
                      gestureNavigationEnabled: true,
                      gestureRecognizers: <
                          Factory<OneSequenceGestureRecognizer>>{
                        Factory<HorizontalDragGestureRecognizer>(
                          () => HorizontalDragGestureRecognizer()
                            ..onUpdate = (_) {},
                        ),
                        Factory<VerticalDragGestureRecognizer>(
                          () => VerticalDragGestureRecognizer()
                            ..onUpdate = (_) {},
                        ),
                        Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer()),
                        Factory<EagerGestureRecognizer>(
                            () => EagerGestureRecognizer())
                      },
                      onProgress: (value) {
                        console("message => $value");
                      },
                      debuggingEnabled: false,
                      zoomEnabled: false,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }

  _getDocumentDetails() async {
    var result = await DocumentViewModel().getDocumentById(widget._documentId);
    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {
              _documentByIdResponse = loaded.data,
              console(
                  "message => ${_documentByIdResponse.getOwnOemSubmissionById?.downloadUrl}")
            },
        (loading) => {
              console("loading => "),
            });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
