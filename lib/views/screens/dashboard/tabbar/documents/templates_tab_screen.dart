import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/model/list_template_response.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/documents/create_document_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/documents/document_view_model.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';

class TemplateTabScreen extends StatefulWidget {
  const TemplateTabScreen({Key? key}) : super(key: key);

  @override
  State<TemplateTabScreen> createState() => _TemplateTabScreenState();
}

class _TemplateTabScreenState extends State<TemplateTabScreen> {
  ListTemplateResponse _listTemplateResponse = ListTemplateResponse();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getTemplateList(),
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (projectSnap.hasError) {
            return const Center(child: Text(unexpectedError));
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/images/errors.svg",
                          color: textColorLight,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        TextView(
                            text:
                                "All document templates are available for online use",
                            textColor: textColorLight,
                            textFontWeight: FontWeight.w400,
                            fontSize: 12),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (_listTemplateResponse.listOwnOemTemplates != null)
                    ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount:
                            _listTemplateResponse.listOwnOemTemplates?.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          return _listTemplates(
                              _listTemplateResponse.listOwnOemTemplates![i]);
                        }),
                  ],
                ),
              ),
            );
          }
        });
  }

  Widget _listTemplates(ListOwnOemTemplates template) {
    return Container(
        margin: const EdgeInsets.only(bottom: 8),
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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateDocumentScreen(
                        template: template,
                      ),
                    ),
                  );
                },
                leading: SvgPicture.asset(
                  "assets/images/ic_pdf_icons.svg",
                ),
                title: TextView(
                    text: template.templateData?.name.toString() ?? "",
                    textColor: textColorDark,
                    isEllipsis: true,
                    textFontWeight: FontWeight.w700,
                    fontSize: 12),
                subtitle: TextView(
                    text: "Available Online",
                    textColor: textColorLight,
                    textFontWeight: FontWeight.w400,
                    fontSize: 13),
                trailing: TextView(
                    text: "Use Template",
                    textColor: visitStatusColor,
                    textFontWeight: FontWeight.w700,
                    fontSize: 12),
              ),
            ],
          ),
        ));
  }

  _getTemplateList() async {
    var result = await DocumentViewModel().getTemplateList();
    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {_listTemplateResponse = loaded.data},
        (loading) => {
              console("loading => "),
            });
  }
}
