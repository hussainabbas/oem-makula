import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/model/child_document_model.dart';
import 'package:makula_oem/helper/model/sign_download_model.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/machines_view_model.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MakulaExpansionTile extends StatefulWidget {
  const MakulaExpansionTile({Key? key, required ChildDocumentsModel document})
      : _document = document,
        super(key: key);

  final ChildDocumentsModel _document;

  @override
  State<MakulaExpansionTile> createState() => _MakulaExpansionTileState();
}

class _MakulaExpansionTileState extends State<MakulaExpansionTile> {
  late String _localPath;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    /* _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    _prepareSaveDir();*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget._document.type == "folder"
        ? _folderDocument()
        : _fileDocument();
  }

  Widget _folderDocument() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      decoration: BoxDecoration(
        color: const Color(0xfff3f4f6),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        childrenPadding: EdgeInsets.zero,
        trailing: Container(
          color: const Color(0xfff3f4f6),
          width: 1,
        ),
        leading: SizedBox(
          width: 55,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset("assets/images/ic-caret-colapse.svg"),
              Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset("assets/images/circle.svg"),
                  SvgPicture.asset("assets/images/ic-folder-filled.svg"),
                ],
              ),
            ],
          ),
        ),
        title: TextView(
            text: widget._document.label.toString(),
            textColor: textColorDark,
            textFontWeight: FontWeight.w700,
            fontSize: 13),
        children: [
          ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              itemCount: widget._document.numberOfChilds,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                return _childDocument(widget._document.childs![i]);
              })
        ],
      ),
    );
  }

  Widget _fileDocument() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      decoration: BoxDecoration(
        color: const Color(0xfff3f4f6),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
        onTap: () {
          _getSignS3Download(widget._document.href.toString());
        },
        trailing: Container(
          color: const Color(0xfff3f4f6),
          width: 1,
        ),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset("assets/images/circle.svg"),
            SvgPicture.asset("assets/images/ic-folder.svg"),
          ],
        ),
        title: TextView(
            text: widget._document.label.toString(),
            textColor: textColorDark,
            textFontWeight: FontWeight.w700,
            fontSize: 13),
      ),
    );
  }

  Widget _childFileDocument(ChildDocumentsModel childDocumentsModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        dense: true,
        onTap: () {
          _getSignS3Download(childDocumentsModel.href.toString());
        },
        trailing: const SizedBox.shrink(),
        leading: Container(
          alignment: Alignment.centerRight,
          width: 40,
          child: childDocumentsModel.type! == "folder"
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset("assets/images/ic-caret-colapse.svg"),
                    SvgPicture.asset("assets/images/ic-folder-filled.svg"),
                  ],
                )
              : SvgPicture.asset("assets/images/ic-folder.svg"),
        ),
        title: TextView(
            text: childDocumentsModel.label.toString(),
            textColor: textColorDark,
            textFontWeight: FontWeight.w600,
            fontSize: 12),
      ),
    );
  }

  Widget _childDocument(ChildDocumentsModel childDocumentsModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 0, 4),
      decoration: BoxDecoration(
        color: const Color(0xfff3f4f6),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: childDocumentsModel.type == "folder"
          ? ExpansionTile(
              tilePadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              expandedCrossAxisAlignment: CrossAxisAlignment.center,
              trailing: const SizedBox.shrink(),
              leading: childDocumentsModel.type! == "folder"
                  ? SizedBox(
                      width: 38,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                              "assets/images/ic-caret-colapse.svg"),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SvgPicture.asset(
                                  "assets/images/ic-folder-filled.svg"),
                            ],
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: 10,
                      child: SvgPicture.asset("assets/images/ic-folder.svg")),
              title: TextView(
                  text: childDocumentsModel.label.toString(),
                  textColor: textColorDark,
                  textFontWeight: FontWeight.w600,
                  fontSize: 12),
              children: [
                ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    itemCount: childDocumentsModel.numberOfChilds,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      return _childDocument(childDocumentsModel.childs![i]);
                    })
              ],
            )
          : _childFileDocument(childDocumentsModel),
    );
  }

  void _launchURL(SignS3DownloadModel model) async {
    console(model.sSignS3Download?.signedRequest ?? "");
    if (await canLaunch(model.sSignS3Download?.signedRequest ?? "")) {
      await launch(model.sSignS3Download?.signedRequest ?? "");
    } else {
      throw 'Could not launch ${model.sSignS3Download?.signedRequest ?? ""}';
    }
  }

  _getSignS3Download(String url) async {
    context.showCustomDialog();
    console("url = $url");
    var mUrl = url.replaceAll(
        "https://workloads-staging-makula-technology-gmbh.s3.amazonaws.com/",
        "");
    console(mUrl);
    var result = await MachineViewModel().getSignS3Download(mUrl);
    result.join(
        (failed) => {
              Navigator.pop(context),
              console("failed => " + failed.exception.toString())
            },
        (loaded) => {Navigator.pop(context), _launchURL(loaded.data)},
        (loading) => {console("loading => ")});
  }
}
