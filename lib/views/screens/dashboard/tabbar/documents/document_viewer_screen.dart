import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/list_template_response.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/widgets/makula_app_bar_gray.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen(
      {Key? key, required String webUrl, required String templateName})
      : _webUrl = webUrl,
        _templateName = templateName,
        super(key: key);

  final String _webUrl;
  final String _templateName;

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBarCustom(
            title: widget._templateName,
          ),
          Expanded(
            child: WebView(
              initialUrl: widget._webUrl,
              allowsInlineMediaPlayback: true,
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: true,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<HorizontalDragGestureRecognizer>(
                  () => HorizontalDragGestureRecognizer()..onUpdate = (_) {},
                ),
                Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer()..onUpdate = (_) {},
                ),
                Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer()),
                Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())
              },
              onProgress:(value) {
                console("message => $value");
              },
              debuggingEnabled: false,
              zoomEnabled: false,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
            ),
          )
        ],
      ),
    );
  }
}
