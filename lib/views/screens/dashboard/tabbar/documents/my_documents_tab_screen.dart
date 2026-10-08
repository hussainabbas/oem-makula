import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/model/list_my_documents_response.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/documents/document_view_model.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDocumentsTabScreen extends StatefulWidget {
  const MyDocumentsTabScreen({Key? key}) : super(key: key);

  @override
  State<MyDocumentsTabScreen> createState() => _MyDocumentsTabScreenState();
}

class _MyDocumentsTabScreenState extends State<MyDocumentsTabScreen> {
  ListMyDocumentsResponse _listMyDocumentsResponse = ListMyDocumentsResponse();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getMyDocumentList(),
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
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _listMyDocumentsResponse
                            .listOwnOemSubmissions?.isNotEmpty ==
                        true
                    ? ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: _listMyDocumentsResponse
                            .listOwnOemSubmissions?.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          return _listMyDocuments(_listMyDocumentsResponse
                              .listOwnOemSubmissions![i]);
                        })
                    : Container(
                  margin: const EdgeInsets.fromLTRB(0, 32, 0, 16),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/images/no-notes.svg"),
                      Text(
                        noDocumentLabel,
                        style: TextStyle(
                            fontSize: 14, fontFamily: 'Manrope', color: textColorLight),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }

  Widget _listMyDocuments(ListOwnOemSubmissions document) {
    console(document.url.toString());
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                onTap: () {
                  _launchURL(document.url.toString());
                  /*Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyDocumentViewerScreen(
                        webUrl: document.url.toString(),
                        templateName: document.templateName.toString(),
                        documentId: document.sId.toString(),
                      ),
                    ),
                  );*/
                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                          decoration: BoxDecoration(
                            color: closedContainerColor,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: TextView(
                              text: "PUBLISHED",
                              textColor: closedStatusColor,
                              textFontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        GestureDetector(
                            onTap: () {
                              _showDeleteAlert(document);
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                              child:
                                  SvgPicture.asset("assets/images/delete.svg"),
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    TextView(
                        text: document.templateName?.toString() ?? "",
                        textColor: textColorDark,
                        isEllipsis: true,
                        textFontWeight: FontWeight.w700,
                        fontSize: 14),
                    const SizedBox(
                      height: 6,
                    ),
                    TextView(
                        text:
                            "${document.machine?.name ?? ""} • ${document.machine?.serialNumber ?? ""}",
                        textColor: textColorLight,
                        isEllipsis: true,
                        textFontWeight: FontWeight.w400,
                        fontSize: 13),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        TextView(
                            text: document.facility?.name ?? "",
                            textColor: primaryColor,
                            isEllipsis: true,
                            textFontWeight: FontWeight.w500,
                            fontSize: 12),
                        const SizedBox(
                          width: 8,
                        ),
                        TextView(
                            text: "•",
                            textColor: primaryColor,
                            isEllipsis: true,
                            textFontWeight: FontWeight.w500,
                            fontSize: 12),
                        const SizedBox(
                          width: 8,
                        ),
                        TextView(
                            text: document.inspectionDate?.contains("-") == true
                                ? document.inspectionDate ?? ""
                                : document.inspectionDate
                                        ?.convertStringToDateTime() ??
                                    "",
                            textColor: textColorDark,
                            isEllipsis: true,
                            textFontWeight: FontWeight.w500,
                            fontSize: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  _getMyDocumentList() async {
    var result = await DocumentViewModel().getMyDocumentList();
    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {_listMyDocumentsResponse = loaded.data},
        (loading) => {
              console("loading => "),
            });
  }

  _showDeleteAlert(ListOwnOemSubmissions document) async {
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: Container(
        height: 280.0,
        width: 400.0,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset("assets/images/delete_document.svg"),
            const SizedBox(
              height: 16,
            ),
            Center(
              child: TextView(
                  text: "Are you sure you want to delete this document?",
                  textColor: textColorDark,
                  textFontWeight: FontWeight.w700,
                  align: TextAlign.center,
                  fontSize: 16),
            ),
            const SizedBox(
              height: 16,
            ),
            Wrap(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _deleteDocument(document);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 1.0),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: TextButton(
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                        child: TextView(
                            text: "Yes, Delete",
                            textColor: Colors.red,
                            textFontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteDocument(document);
                      },
                    ),
                    /*child: FlatButton(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteDocument(document);
                      },
                      child: const TextView(
                          text: "Yes, Delete",
                          textColor: Colors.red,
                          textFontWeight: FontWeight.w700,
                          fontSize: 14),
                      textColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: borderColor,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),
                    ),*/
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      border: Border.all(color: borderColor, width: 1.0),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: TextButton(
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: TextView(
                            text: "No, Cancel",
                            textColor: Colors.white,
                            textFontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(primaryColor),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => errorDialog);
  }

  _deleteDocument(ListOwnOemSubmissions document) async {
    console("message = ${document.sId}");
    context.showCustomDialog();
    var result = await DocumentViewModel().deleteDocument(document.sId ?? "");
    Navigator.pop(context);
    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {_refresh()},
        (loading) => {
              console("loading => "),
            });
  }

  _refresh() {
    setState(() {});
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
