import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/context_function.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/image_full_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/signature_procedure_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/procedure_provider.dart';
import 'package:makula_oem/views/widgets/custom_elevated_button.dart';
import 'package:makula_oem/views/widgets/dotter_border.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class ProcedureScreen extends StatefulWidget {
  final ListOwnOemProcedureTemplates? templates;
  final String? state;
  final String? pdfUrl;

  const ProcedureScreen({super.key, required this.templates, required this.state, required this.pdfUrl});

  @override
  State<ProcedureScreen> createState() => _ProcedureScreenState();
}

class _ProcedureScreenState extends State<ProcedureScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));

    // Extract the procedure from the templates
    final ListOwnOemProcedureTemplates? templates = widget.templates;
    final procedures = templates?.children ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios)),
        backgroundColor: Colors.grey.shade200,
        actions: [
          SvgPicture.asset("assets/images/notification.svg"),
          const SizedBox(
            width: 16,
          )
        ],
        title: TextView(
            text: "Packaging machine / ${templates?.name}",
            textColor: textColorDark,
            textFontWeight: FontWeight.bold,
            fontSize: 14),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(

                              onTap: () {
                                launchURL(widget.pdfUrl ?? "");

                              },
                              child: SvgPicture.asset("assets/images/ghost_button.svg")),

                          Container(
                              decoration: BoxDecoration(
                                  color: widget.state == "NOT_STARTED"
                                      ? lightGray
                                      : closedContainerColor,
                                  borderRadius:
                                  BorderRadius.circular(8)),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.fromLTRB(
                                  8, 4, 4, 5),
                              child: TextView(
                                  align: TextAlign.center,
                                  text: widget.state?.replaceAll("_", " ") ?? "",
                                  textColor: widget.state == "NOT_STARTED"
                                      ? textColorLight
                                      : closedStatusColor,
                                  textFontWeight: FontWeight.normal,
                                  fontSize: 12)),

                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextView(
                          text: templates?.name ?? "",
                          textColor: textColorDark,
                          textFontWeight: FontWeight.bold,
                          fontSize: 18),
                      const SizedBox(
                        height: 16,
                      ),
                      TextView(
                          text: templates?.description ?? "",
                          textColor: textColorDark,
                          textFontWeight: FontWeight.normal,
                          fontSize: 12),
                      for (var procedure in procedures)
                        FieldWidget(
                          fieldData: procedure,
                          isBorderShowing: true,
                        ),
                      const SizedBox(height: 16),
                      //SIGNATURE

                      if (templates?.signatures?.isNotEmpty == true)
                        SignatureWidget(
                          signatureModel: templates?.signatures,
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.state != "FINALIZED")
              const ActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class SignatureWidget extends StatelessWidget {
  final List<SignatureModel>? signatureModel;

  const SignatureWidget({super.key, required this.signatureModel});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.fullWidth(),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: lightGray, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(
                text: "Signature",
                textColor: textColorDark,
                textFontWeight: FontWeight.w500,
                fontSize: 14),
            const SizedBox(
              height: 16,
            ),
            ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                          text: "Date Signed",
                          textColor: textColorDark,
                          textFontWeight: FontWeight.normal,
                          fontSize: 12),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                          padding: const EdgeInsets.all(16),
                          width: context.fullWidth(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextView(
                                  text: "Select Date",
                                  textColor: textColorLight,
                                  textFontWeight: FontWeight.normal,
                                  fontSize: 12),
                              Icon(
                                Icons.calendar_month,
                                color: textColorLight,
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 16,
                      ),
                      TextView(
                          text: "OEM agent name",
                          textColor: textColorDark,
                          textFontWeight: FontWeight.normal,
                          fontSize: 12),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          style: TextStyle(color: textColorDark, fontSize: 12),
                          // Use the field name as the key
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Name",
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            return null;
                          },
                          onChanged: (value) {
                            final formStateProvider =
                                Provider.of<ProcedureProvider>(context,
                                    listen: false);
                            formStateProvider.setFieldValue("Signature", value);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextView(
                          text: "Signature",
                          textColor: textColorDark,
                          textFontWeight: FontWeight.normal,
                          fontSize: 12),
                      const SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SignatureProcedureScreen()),
                          );
                        },
                        child: Container(
                            padding: const EdgeInsets.all(16),
                            height: 200,
                            width: context.fullWidth(),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextView(
                                text: "Sign here",
                                textColor: textColorLight,
                                textFontWeight: FontWeight.normal,
                                fontSize: 12)),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 30,
                  );
                },
                itemCount: signatureModel?.length ?? 0),
          ],
        ));
  }
}

// class ProcedureWidget extends StatelessWidget {
//   final ChildrenModel procedureData;
//
//   const ProcedureWidget({super.key, required this.procedureData});
//
//   @override
//   Widget build(BuildContext context) {
//     final procedureChildren = procedureData.children ?? [];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         FieldWidget(
//           fieldData: procedureData,
//           isBorderShowing: true,
//         ),
//         // for (var child in procedureChildren)
//         //   FieldWidget(
//         //     fieldData: child,
//         //     isBorderShowing: true,
//         //   ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
// }
//
// class TemplateWidget extends StatelessWidget {
//   final ChildrenModel templateData;
//
//   const TemplateWidget({super.key, required this.templateData});
//
//   @override
//   Widget build(BuildContext context) {
//     final templateChildren = templateData.children;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         for (var child in templateChildren!)
//           FieldWidget(
//             fieldData: child,
//             isBorderShowing: true,
//           ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
// }

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final formStateProvider =
        Provider.of<ProcedureProvider>(context, listen: false);
    return ChangeNotifierProvider.value(
      value: Provider.of<ProcedureProvider>(context, listen: true),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: CustomElevatedButton(
                    backgroundColor: visitContainerColor,
                    textColor: primaryColor,
                    borderRadius: 8,
                    title: "Save as Draft",
                    onPressed: () {
                      // final formStateProvider = Provider.of<ProcedureProvider>(
                      //     context,
                      //     listen: false);
                      // formStateProvider.clearFieldValues();
                      // saveAsDraft();

                      final formStateProvider = Provider.of<ProcedureProvider>(
                          context,
                          listen: false);
                      finalize(formStateProvider.fieldValues, context);
                    })),
            const SizedBox(
              width: 16,
            ),
            Expanded(
                child: CustomElevatedButton(
                    backgroundColor:
                        (formStateProvider.isValid || Provider.of<ProcedureProvider>(
                        context,
                            listen: false).fieldValues.isEmpty) ? primaryColor : Colors.grey,
                    textColor: Colors.white,
                    borderRadius: 8,
                    isValid: formStateProvider.isValid || Provider.of<ProcedureProvider>(
                        context,
                        listen: false).fieldValues.isEmpty,
                    title: "Finalize",
                    onPressed: () {
                      final formStateProvider = Provider.of<ProcedureProvider>(
                          context,
                          listen: false);
                      if (formStateProvider.fieldValues.isNotEmpty) {
                        finalize(formStateProvider.fieldValues, context);
                      }
                    })),
          ],
        ),
      ),
    );
  }

  void saveAsDraft() {}

  void finalize(Map<String, dynamic> fieldValues, BuildContext context) {
    final formStateProvider = Provider.of<ProcedureProvider>(
        context,
        listen: false);
    console('Finalizing with values: $fieldValues');
    console('Finalizing with values: ${formStateProvider.isValid}');
  }
}

class FieldWidget extends StatelessWidget {
  final ChildrenModel fieldData;
  final bool isBorderShowing;

  const FieldWidget(
      {super.key, required this.fieldData, required this.isBorderShowing});

  @override
  Widget build(BuildContext context) {
    final String type = fieldData.type ?? "";
    final String name = fieldData.name ?? "";
    final String description = fieldData.description ?? "";
    final bool isRequired = fieldData.isRequired ?? false;
    console("FieldWidget => $type");
    switch (type) {
      case 'HEADING':
        return TextWidget(
          name: name,
          fieldData: fieldData,
          isRequired: isRequired,
          context: context,
        );
      case 'TEXT_AREA_FIELD':
        return TextFieldWidget(
            name: name,
            fieldData: fieldData,
            isRequired: isRequired,
            keyboardType: TextInputType.text,
            description: description,
            isBorderShowing: isBorderShowing,
            context: context);
      case 'NUMBER_FIELD':
        return TextFieldWidget(
            name: name,
            fieldData: fieldData,
            isRequired: isRequired,
            description: description,
            isBorderShowing: isBorderShowing,
            keyboardType: TextInputType.number,
            context: context);
      case 'DATE_FIELD':
        return DatePickerWidget(
            name: name,
            fieldData: fieldData,
            isRequired: isRequired,
            description: description,
            context: context);
      case 'SECTION':
        return SectionWidget(sectionData: fieldData);
      case 'CHECKLIST_FIELD':
        return ChecklistFieldWidget(fieldData: fieldData, context: context);
      case 'CHECKBOX_FIELD':
        return CheckboxFieldWidget(
          fieldData: fieldData,
          context: context,
        );
      case 'IMAGE_UPLOADER_FIELD':
        return ImageUploaderWidget(
            name: fieldData.name ?? "",
            fieldData: fieldData,
            isRequired: fieldData.isRequired ?? false,
            description: fieldData.description ?? "",
            context: context);
      case 'PARTS_FIELD':
        return PartsFieldWidget(
            fieldData: fieldData,
            name: fieldData.name ?? "",
            isRequired: fieldData.isRequired ?? false,
            description: fieldData.description ?? "",
            context: context);
      case 'SINGLE_SELECT_FIELD':
        return SingleSelectFieldWidget(
            name: fieldData.name ?? "",
            isRequired: fieldData.isRequired ?? false,
            description: fieldData.description ?? "",
            fieldData: fieldData,
            context: context);
      case 'TABLE_FIELD':
        return TableFieldWidget(fieldData: fieldData, context: context);
      case 'MEMBER_FIELD':
        return MemberFieldWidget(
          name: fieldData.name ?? "",
          fieldData: fieldData,
          context: context,
          isRequired: fieldData.isRequired ?? false,
          description: fieldData.description ?? "",
        );

      // Add more cases for other field types as needed
      default:
        return Container(); // Placeholder for unknown field types
    }
  }
}

class TableFieldWidget extends StatefulWidget {
  final ChildrenModel fieldData;
  final BuildContext context;

  TableFieldWidget(
      {super.key, required this.fieldData, required this.context}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", null);
      });
    }
  }

  @override
  _TableFieldWidgetState createState() => _TableFieldWidgetState();
}

class _TableFieldWidgetState extends State<TableFieldWidget> {
  List<List<TextEditingController>> rows = [];

  @override
  void initState() {
    super.initState();
    // Initialize with one empty row
    addRow();
  }

  void addRow() {
    // Create a new row with empty controllers
    List<TextEditingController> newRow = List.generate(
      widget.fieldData.tableOption?.columns?.length ?? 0,
      (index) => TextEditingController(),
    );
    // Add the new row to the list
    setState(() {
      rows.add(newRow);
    });
  }

  void deleteRow(int rowIndex) {
    // Remove the selected row
    setState(() {
      rows.removeAt(rowIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        TextView(
            text:
                "${widget.fieldData.name ?? ""} ${widget.fieldData.isRequired ?? false ? "*" : ""}",
            textColor: textColorLight,
            textFontWeight: FontWeight.normal,
            fontSize: 14),
        if (widget.fieldData.description != null)
          Column(
            children: [
              const SizedBox(
                height: 4,
              ),
              TextView(
                  text: widget.fieldData.description ?? "",
                  textColor: Colors.black,
                  textFontWeight: FontWeight.w500,
                  fontSize: 14),
            ],
          ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1)),
          child: Column(
            children: [
              ListView.builder(
                itemCount: rows.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, mainIndex) {
                  // Show a container for each row
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        decoration: BoxDecoration(
                          color: chatBubbleSenderClosed,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextView(
                                text: "Row ${mainIndex + 1}",
                                textColor: textColorLight,
                                textFontWeight: FontWeight.normal,
                                fontSize: 12),
                            GestureDetector(
                                onTap: () {
                                  deleteRow(mainIndex);
                                },
                                child: SvgPicture.asset(
                                    "assets/images/ic-delete.svg"))
                          ],
                        ),
                      ),

                      ListView.separated(
                        itemCount:
                            widget.fieldData.tableOption?.columns?.length ?? 0,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, childIndex) {
                          var columnItem = widget
                              .fieldData.tableOption?.columns?[childIndex];
                          return Container(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: TextView(
                                        text: columnItem?.heading ?? "",
                                        textColor: Colors.black,
                                        textFontWeight: FontWeight.normal,
                                        fontSize: 12)),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: rows[mainIndex][childIndex],
                                    decoration: const InputDecoration(
                                        hintText: '-',
                                        border: InputBorder.none),
                                    onChanged: (value) {
                                      final formStateProvider =
                                          Provider.of<ProcedureProvider>(
                                              context,
                                              listen: false);

                                      List<List<String>> currentTableData =
                                          formStateProvider.fieldValues[
                                                  widget.fieldData.name] ??
                                              [];

                                      // Update the value at the specified row and cell
                                      while (currentTableData.length <=
                                          mainIndex) {
                                        currentTableData.add(List.filled(
                                            widget.fieldData.tableOption
                                                    ?.columns?.length ??
                                                0,
                                            ''));
                                      }
                                      currentTableData[mainIndex][childIndex] =
                                          value;

                                      // Save the updated table data in ProcedureProvider
                                      formStateProvider.setFieldValue(
                                          widget.fieldData.name ?? "",
                                          currentTableData);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                      ),

                      // buildRow(index),
                    ],
                  );
                },
              ),
              const Divider(),
              GestureDetector(
                onTap: () {
                  addRow();
                },
                child: Container(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: TextView(
                        text: "+ Add Row",
                        textColor: textColorLight,
                        textFontWeight: FontWeight.normal,
                        fontSize: 14)),
              ),
            ],
          ),
        ),
        AttachmentWidget(fieldData: widget.fieldData),
        const SizedBox(
          height: 8,
        ),
        const Divider(),
      ],
    );
  }

  Widget buildRow(int rowIndex) {
    return DataTable(
      columns: List.generate(
        widget.fieldData.tableOption?.columns?.length ?? 0,
        (tableIndex) {
          return DataColumn(label: Text('Column ${tableIndex + 1}'));
        },
      ),
      rows: [
        DataRow(
          cells: List.generate(
            widget.fieldData.tableOption?.columns?.length ?? 0,
            (cellIndex) {
              return DataCell(
                TextFormField(
                  controller: rows[rowIndex][cellIndex],
                  decoration: const InputDecoration(
                    hintText: 'Enter data',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    for (var row in rows) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}

class ImageUploaderWidget extends StatelessWidget {
  final String name;
  final bool isRequired;
  final String description;
  final BuildContext context;
  final ChildrenModel fieldData;

  ImageUploaderWidget(
      {super.key,
      required this.name,
      required this.fieldData,
      required this.isRequired,
      required this.description,
      required this.context}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.fullWidth(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 16,
          ),
          TextView(
              text: "$name ${isRequired ? "*" : ""}",
              textColor: textColorLight,
              textFontWeight: FontWeight.normal,
              fontSize: 14),
          Column(
            children: [
              const SizedBox(
                height: 4,
              ),
              TextView(
                  text: description,
                  textColor: Colors.black,
                  textFontWeight: FontWeight.w500,
                  fontSize: 14),
            ],
          ),
          GestureDetector(
            onTap: () {
              final formStateProvider =
                  Provider.of<ProcedureProvider>(context, listen: false);
              formStateProvider.setImageFieldValue(
                  fieldData.name ?? "", "randomString");
            },
            child: CustomPaint(
              painter: DottedBorderPainter(),
              child: SizedBox(
                width: context.fullWidth(),
                // Your content goes here
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Image.asset("assets/images/upload_file.png"),
                      // SvgPicture.asset("assets/images/upload-file.svg", color: Colors.red, width: 200,),
                      const SizedBox(
                        height: 16,
                      ),
                      TextView(
                          text: "Upload file from your device",
                          textColor: primaryColor,
                          textFontWeight: FontWeight.normal,
                          fontSize: 12),
                      const SizedBox(
                        height: 10,
                      ),
                      TextView(
                          text: "Supported formats: JPEG, PNG; up to 10MB",
                          textColor: textColorLight,
                          textFontWeight: FontWeight.normal,
                          fontSize: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          AttachmentWidget(fieldData: fieldData),
          const SizedBox(
            height: 10,
          ),
          const Divider()
        ],
      ),
    );
  }
}

class PartsFieldWidget extends StatelessWidget {
  final String name;
  final bool isRequired;
  final String description;
  final BuildContext context;
  final ChildrenModel fieldData;

  PartsFieldWidget(
      {super.key,
      required this.name,
      required this.fieldData,
      required this.isRequired,
      required this.description,
      required this.context}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.fullWidth(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 16,
          ),
          TextView(
              text: "$name ${isRequired ? "*" : ""}",
              textColor: textColorLight,
              textFontWeight: FontWeight.normal,
              fontSize: 14),
          Column(
            children: [
              const SizedBox(
                height: 4,
              ),
              TextView(
                  text: description,
                  textColor: Colors.black,
                  textFontWeight: FontWeight.w500,
                  fontSize: 14),
            ],
          ),
          DropdownSearch<String>(
            //mode: Mode.MENU,
            //showSearchBox: true,
            items: const ["A", "B"],
            selectedItem: "Choose Part",
            itemAsString: (String? u) => u ?? "",
            onChanged: (String? data) {
              final formStateProvider =
                  Provider.of<ProcedureProvider>(context, listen: false);

              formStateProvider.setFieldValue(name, data);
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: "Choose Part",
                contentPadding: const EdgeInsets.only(left: 16, bottom: 8),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: .5),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ),
          ),
          AttachmentWidget(fieldData: fieldData),
          const SizedBox(
            height: 8,
          ),
          const Divider()
        ],
      ),
    );
  }
}

class SingleSelectFieldWidget extends StatelessWidget {
  final String name;
  final bool isRequired;
  final String description;
  final BuildContext context;
  final ChildrenModel fieldData;

  SingleSelectFieldWidget(
      {super.key,
      required this.name,
      required this.isRequired,
      required this.description,
      required this.fieldData,
      required this.context}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = fieldData.options ?? [];
    return SizedBox(
      width: context.fullWidth(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 16,
          ),
          TextView(
              text: "$name ${isRequired ? "*" : ""}",
              textColor: textColorLight,
              textFontWeight: FontWeight.normal,
              fontSize: 14),
          Column(
            children: [
              const SizedBox(
                height: 4,
              ),
              TextView(
                  text: description,
                  textColor: Colors.black,
                  textFontWeight: FontWeight.w500,
                  fontSize: 14),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 1,
                  color: borderColor,
                )),
            child: Column(
              children: [
                for (var option in options ?? [])
                  RadioListTile<OptionsModel?>(
                    contentPadding: EdgeInsets.zero,
                    title: TextView(
                      text: option.name ?? '',
                      textColor: textColorDark,
                      textFontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                    value: option,
                    groupValue: Provider.of<ProcedureProvider>(context)
                                .fieldValues[name] ==
                            option.name
                        ? option
                        : null,
                    onChanged: (OptionsModel? value) {
                      print("SingleSelectFieldWidget => $value");
                      print(
                          "SingleSelectFieldWidget option.name => ${option.name}");
                      final formStateProvider = Provider.of<ProcedureProvider>(
                          context,
                          listen: false);

                      // Save only the name in fieldValues
                      formStateProvider.setFieldValue(name, option.name);
                    },
                  )
                // RadioListTile<String>(
                //   contentPadding: EdgeInsets.zero,
                //   title: TextView(
                //     text: option.name ?? '',
                //     textColor: textColorDark,
                //     textFontWeight: FontWeight.normal,
                //     fontSize: 12,
                //   ),
                //   value: "",//Provider.of<ProcedureProvider>(context).fieldValues[name] ?? "",
                //   groupValue: fieldData.options?[0].name,
                //   onChanged: (String? value) {
                //     console("SingleSelectFieldWidget => $value");
                //     console("SingleSelectFieldWidget fieldData.options?[0].name => ${fieldData.options?[0].name}");
                //     final formStateProvider = Provider.of<ProcedureProvider>(context, listen: false);
                //
                //     formStateProvider.setFieldValue(name, value);
                //   },
                // ),
              ],
            ),
          ),
          AttachmentWidget(fieldData: fieldData),
          const SizedBox(
            height: 8,
          ),
          const Divider()
        ],
      ),
    );
  }
}

class MemberFieldWidget extends StatelessWidget {
  final String name;
  final bool isRequired;
  final String description;
  final BuildContext context;
  final ChildrenModel fieldData;

  MemberFieldWidget(
      {super.key,
      required this.name,
      required this.fieldData,
      required this.isRequired,
      required this.description,
      required this.context}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.fullWidth(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 16,
          ),
          TextView(
              text: "$name ${isRequired ? "*" : ""}",
              textColor: textColorLight,
              textFontWeight: FontWeight.normal,
              fontSize: 14),
          Column(
            children: [
              const SizedBox(
                height: 4,
              ),
              TextView(
                  text: description,
                  textColor: Colors.black,
                  textFontWeight: FontWeight.w500,
                  fontSize: 14),
            ],
          ),
          DropdownSearch<String>(
            //mode: Mode.MENU,
            //showSearchBox: true,
            items: const ["A", "B"],
            selectedItem: "Select OEM Agent",
            itemAsString: (String? u) => u ?? "",
            onChanged: (String? data) {
              final formStateProvider =
                  Provider.of<ProcedureProvider>(context, listen: false);

              formStateProvider.setFieldValue(name, data);
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: "Select Facility",
                contentPadding: const EdgeInsets.only(left: 16, bottom: 8),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: .5),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          AttachmentWidget(fieldData: fieldData),
          const SizedBox(
            height: 8,
          ),
          const Divider()
        ],
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  final String name;
  final bool isRequired;
  final BuildContext context;
  final ChildrenModel fieldData;

  TextWidget(
      {super.key,
      required this.name,
      required this.isRequired,
      required this.fieldData,
      required this.context}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        TextView(
            text: name,
            textColor: textColorDark,
            textFontWeight: FontWeight.bold,
            fontSize: 18),
        AttachmentWidget(fieldData: fieldData),
      ],
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  final String name;
  final String description;
  final bool isRequired;
  final bool isBorderShowing;
  final TextInputType keyboardType;
  final BuildContext context;
  final ChildrenModel fieldData;

  TextFieldWidget(
      {super.key,
      required this.name,
      required this.description,
      required this.isBorderShowing,
      required this.isRequired,
      required this.context,
      required this.fieldData,
      required this.keyboardType}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isBorderShowing
          ? const EdgeInsets.fromLTRB(16, 8, 16, 8)
          : EdgeInsets.zero,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isBorderShowing ? 8 : 0),
          color: Colors.white,
          border: Border.all(
              color: isBorderShowing ? chatBubbleSenderClosed : Colors.white,
              width: isBorderShowing ? 1 : 0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 8,
          ),
          TextView(
              text: "$name ${isRequired ? "*" : ""}",
              textColor: textColorLight,
              textFontWeight: FontWeight.normal,
              fontSize: 12),
          const SizedBox(
            height: 4,
          ),
          TextView(
              text: description,
              textColor: textColorDark,
              textFontWeight: FontWeight.normal,
              fontSize: 12),

          const SizedBox(
            height: 8,
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: chatBubbleSenderClosed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              key: Key(name),
              style: TextStyle(color: textColorDark, fontSize: 12),
              // Use the field name as the key
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Type here...",
              ),
              keyboardType: keyboardType,
              validator: (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'This field is required';
                }
                return null;
              },
              onChanged: (value) {
                final formStateProvider =
                    Provider.of<ProcedureProvider>(context, listen: false);
                formStateProvider.setFieldValue(name, value);
              },
            ),
          ),

          AttachmentWidget(fieldData: fieldData),
          const SizedBox(
            height: 8,
          ),

          if (!isBorderShowing) const Divider(),
          // TextField(
          //   keyboardType: keyboardType,
          // ),
        ],
      ),
    );
  }
}

class DatePickerWidget extends StatelessWidget {
  final String name;
  final String description;
  final bool isRequired;
  final BuildContext context;
  final ChildrenModel fieldData;

  DatePickerWidget(
      {super.key,
      required this.name,
      required this.isRequired,
      required this.context,
      required this.fieldData,
      required this.description}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate;

    return ChangeNotifierProvider.value(
      value: Provider.of<ProcedureProvider>(context, listen: true),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 16,
          ),
          TextView(
              text: "$name ${isRequired ? "*" : ""}",
              textColor: Colors.black,
              textFontWeight: FontWeight.normal,
              fontSize: 14),
          const SizedBox(
            height: 4,
          ),
          TextView(
              text: description,
              textColor: Colors.black,
              textFontWeight: FontWeight.w500,
              fontSize: 14),
          const SizedBox(
            height: 8,
          ),
          GestureDetector(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null && pickedDate != selectedDate) {
                // setState(() {
                //   _selectedDate = pickedDate;
                // });
                if (context.mounted) {
                  // Save the value to the state
                  final formStateProvider =
                  Provider.of<ProcedureProvider>(context, listen: false);
                  formStateProvider.setFieldValue(name, DateFormat('dd/MM/yyyy').format(pickedDate));
                }
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: chatBubbleSenderClosed,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextView(
                      text: Provider.of<ProcedureProvider>(context, listen: false).fieldValues[name] ?? "mm/dd/yyy",
                      textColor: Colors.black,
                      textFontWeight: FontWeight.normal,
                      fontSize: 14),
                  const Icon(Icons.calendar_month)
                ],
              ),
            ),
          ),
          AttachmentWidget(fieldData: fieldData),
          const SizedBox(
            height: 8,
          ),
          const Divider(),
        ],
      )
    );
  }
}

class SectionWidget extends StatelessWidget {
  final ChildrenModel sectionData;

  const SectionWidget({super.key, required this.sectionData});

  @override
  Widget build(BuildContext context) {
    final sectionChildren = sectionData.children;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: chatBubbleSenderClosed, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
              text: sectionData.name ?? "",
              textColor: textColorDark,
              textFontWeight: FontWeight.bold,
              fontSize: 14),
          for (var child in sectionChildren ?? [])
            FieldWidget(
              fieldData: child,
              isBorderShowing: false,
            ),
        ],
      ),
    );
  }
}

class ChecklistFieldWidget extends StatelessWidget {
  final ChildrenModel fieldData;
  final BuildContext context;

  ChecklistFieldWidget(
      {super.key, required this.fieldData, required this.context}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = fieldData.name ?? "";
    final String description = fieldData.description ?? "";
    final bool isRequired = fieldData.isRequired ?? false;
    final options = fieldData.options ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 16,
        ),
        TextView(
            text: "$name ${isRequired ? "*" : ""}",
            textColor: textColorLight,
            textFontWeight: FontWeight.normal,
            fontSize: 12),
        const SizedBox(
          height: 4,
        ),
        TextView(
            text: description,
            textColor: textColorDark,
            textFontWeight: FontWeight.normal,
            fontSize: 12),
        for (var option in options)
          CheckboxListTile(
            contentPadding: const EdgeInsets.all(0),

            title: TextView(
                text: option.name ?? "",
                textColor: textColorDark,
                textFontWeight: FontWeight.normal,
                fontSize: 12),
            value: Provider.of<ProcedureProvider>(context)
                    .fieldValues[name]
                    ?.contains(option.name) ??
                false,
            // Set the actual value based on your logic
            onChanged: (value) {
              final formStateProvider =
                  Provider.of<ProcedureProvider>(context, listen: false);

              if (value != null) {
                // Update the state with the selected options
                List<String> selectedOptions = List<String>.from(
                    formStateProvider.fieldValues[name] ?? []);
                if (value) {
                  selectedOptions.add(option.name ?? "");
                } else {
                  selectedOptions.remove(option.name);
                }

                formStateProvider.setFieldValue(name, selectedOptions);
              }
            },
          ),
        AttachmentWidget(fieldData: fieldData),
        const SizedBox(
          height: 16,
        ),
        const Divider()
      ],
    );
  }
}

class CheckboxFieldWidget extends StatelessWidget {
  final ChildrenModel fieldData;
  final BuildContext context;

  CheckboxFieldWidget(
      {super.key, required this.fieldData, required this.context}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final String name = fieldData['name'];
    // final bool isRequired = fieldData['isRequired'];
    // final String description = fieldData['description'] ?? "";
    // final List<dynamic> options = fieldData['options'];

    final String name = fieldData.name ?? "";
    final String description = fieldData.description ?? "";
    final bool isRequired = fieldData.isRequired ?? false;
    final options = fieldData.options ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 16,
        ),
        TextView(
            text: "$name ${isRequired ? "*" : ""}",
            textColor: Colors.black,
            textFontWeight: FontWeight.normal,
            fontSize: 14),
        const SizedBox(
          height: 4,
        ),
        TextView(
            text: description,
            textColor: Colors.black,
            textFontWeight: FontWeight.w500,
            fontSize: 14),
        CheckboxListTile(
          contentPadding: const EdgeInsets.all(0),
          title: TextView(
              text: fieldData.name ?? "",
              textColor: Colors.black,
              textFontWeight: FontWeight.normal,
              fontSize: 14),
          value: Provider.of<ProcedureProvider>(context)
                  .fieldValues[name]
                  ?.contains(fieldData.name) ??
              false,
          // Set the actual value based on your logic
          onChanged: (value) {
            final formStateProvider =
                Provider.of<ProcedureProvider>(context, listen: false);

            if (value != null) {
              // Update the state with the selected options
              List<String> selectedOptions =
                  List<String>.from(formStateProvider.fieldValues[name] ?? []);
              if (value) {
                selectedOptions.add(fieldData.name ?? "");
              } else {
                selectedOptions.remove(fieldData.name);
              }

              formStateProvider.setFieldValue(name, selectedOptions);
            }
          },
        ),
        AttachmentWidget(fieldData: fieldData),
        const Divider()
      ],
    );
  }
}

class AttachmentWidget extends StatelessWidget {
  final ChildrenModel fieldData;

  const AttachmentWidget({super.key, required this.fieldData});

  @override
  Widget build(BuildContext context) {
    if (fieldData.attachments?.isNotEmpty == true) {
      return ExpansionTile(
        trailing: const SizedBox(),
        shape: Border.all(width: 0),
        title: const Row(
          children: [
            TextView(
                text: "View Attachments",
                textColor: Colors.black,
                textFontWeight: FontWeight.normal,
                fontSize: 12),
            Icon(Icons.keyboard_arrow_down)
          ],
        ),
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: fieldData.attachments?.length,
            itemBuilder: (context, index) {
              var item = fieldData.attachments?[index];
              return ListTile(
                onTap: () {
                  if (item?.type?.contains("image") == true) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ImageViewFullScreen(
                        imageURL: item?.url ?? "",
                      ),
                    ));
                  } else {
                    launchURL(item?.url ?? "");
                  }
                },
                contentPadding: const EdgeInsets.fromLTRB(16,0,16,0),
                leading: Icon(Icons.document_scanner, color: textColorLight, size: 36,),
                title: TextView(text: item?.name ?? "", textColor: textColorLight, textFontWeight: FontWeight.bold, fontSize: 12, isEllipsis: true,),
                subtitle: TextView(text: "${getFileType(item?.type ?? "")} • ${getFileSizeInKBs(item?.size ?? "")}", textColor: textColorLight, textFontWeight: FontWeight.normal, fontSize: 12),
              );
            },
          )
        ],
      );
    }
    return const SizedBox();
  }


}


/*
* GET PART LIST
*
{operationName: "ListOwnOemInventoryPart",…}
operationName
:
"ListOwnOemInventoryPart"
query
:
"query ListOwnOemInventoryPart($params: InputInventoryQueryParams) {\n  listOwnOemInventoryPart(params: $params) {\n    currentPage\n    limit\n    skip\n    totalCount\n    parts {\n      ...InventoryPartBasicData\n      __typename\n    }\n    __typename\n  }\n}\n\nfragment InventoryPartBasicData on InventoryPart {\n  _id\n  name\n  articleNumber\n  description\n  image\n  thumbnail\n  oem {\n    ...OemBasicData\n    __typename\n  }\n  customFields {\n    _id\n    fieldId {\n      ...CustomAdditionFieldData\n      __typename\n    }\n    value\n    __typename\n  }\n  __typename\n}\n\nfragment OemBasicData on Oem {\n  _id\n  logo\n  thumbnail\n  backgroundColor\n  brandLogo\n  heading\n  subHeading\n  paragraph\n  textColor\n  name\n  urlOemFacility\n  slug\n  allowFollowersMyWorkOrders\n  statuses {\n    _id\n    label\n    color\n    __typename\n  }\n  notification {\n    email {\n      internal\n      internalUsers {\n        _id\n        name\n        __typename\n      }\n      notifyOnMaintenanceWorkOrderCreation\n      maintenanceWorkOrderCreationNotifyTo {\n        _id\n        name\n        __typename\n      }\n      notifyOnMessageOnUnassignedWorkOrder\n      messageOnUnassignedWorkOrderNotifyTo {\n        _id\n        name\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n  __typename\n}\n\nfragment CustomAdditionFieldData on CustomAdditionalField {\n  _id\n  type\n  slug\n  label\n  fieldType\n  isAdditionalField\n  enabled\n  created_at\n  order\n  oem {\n    _id\n    name\n    __typename\n  }\n  options {\n    _id\n    value\n    color\n    __typename\n  }\n  __typename\n}\n"
variables
:
{params: {limit: 100, skip: 0, where: {searchQuery: ""}}}
*
*
*
* */



/*
* TODO
* WHEN CLICK ON FINALIZE SHOW A POPUP
* 1. IF SIGNATURE
*
* 2. UPLOAD SIGNATURE
{variables: {filename: "Signature-sign", filetype: "image/png",…},…}
query
:
"mutation ($filename: String!, $filetype: String!, $type: String, $forceCustomPath: Boolean) {\n  _safeSignS3(filename: $filename, filetype: $filetype, type: $type, forceCustomPath: $forceCustomPath) {\n    url\n    signedRequest\n    __typename\n  }\n}\n"
variables
:
{filename: "Signature-sign", filetype: "image/png",…}
filename
:
"Signature-sign"
filetype
:
"image/png"
forceCustomPath
:
true
type
:
"oem/mmmtechdemo/procedures/6581a97a9944a8500087a37d/file"
*
* 3. GET SIGNATURE
{variables: {filename: "_67b78c6d-c450-4f31-ba56-f3da69c24401.jpeg", filetype: "image/jpeg",…},…}
query
:
"mutation ($filename: String!, $filetype: String!, $type: String, $forceCustomPath: Boolean) {\n  _safeSignS3(filename: $filename, filetype: $filetype, type: $type, forceCustomPath: $forceCustomPath) {\n    url\n    signedRequest\n    __typename\n  }\n}\n"
variables
:
{filename: "_67b78c6d-c450-4f31-ba56-f3da69c24401.jpeg", filetype: "image/jpeg",…}
*
* 4. FINALIZE API CALL
{operationName: "finalizeOwnOemProcedure", variables: {input: {_id: "6581a97a9944a8500087a37d",…}},…}
operationName
:
"finalizeOwnOemProcedure"
query
:
"mutation finalizeOwnOemProcedure($input: InputFinalizeProcedure!) {\n  finalizeOwnOemProcedure(input: $input)\n}\n"
variables
:
{input: {_id: "6581a97a9944a8500087a37d",…}}
*
*5. GET PROCEDURE BY ID API CALL
{operationName: "getOwnOemProcedureById", variables: {id: "6581a97a9944a8500087a37d"},…}
operationName
:
"getOwnOemProcedureById"
query
:
"query getOwnOemProcedureById($id: ID!) {\n  getOwnOemProcedureById(id: $id) {\n    ...ProcedureInstanceFullData\n    __typename\n  }\n}\n\nfragment ProcedureInstanceFullData on Procedure {\n  _id\n  name\n  state\n  description\n  createdAt\n  updatedAt\n  pdfUrl\n  signatures {\n    _id\n    signatoryTitle\n    name\n    date\n    signatureUrl\n    __typename\n  }\n  submittedBy {\n    _id\n    name\n    __typename\n  }\n  children {\n    ...ProcedureInstanceChildren\n    children {\n      ...ProcedureInstanceChildren\n      __typename\n    }\n    __typename\n  }\n  __typename\n}\n\nfragment ProcedureInstanceChildren on ProcedureNode {\n  _id\n  name\n  type\n  description\n  isRequired\n  value\n  attachments {\n    _id\n    name\n    type\n    url\n    size\n    __typename\n  }\n  options {\n    _id\n    name\n    __typename\n  }\n  tableOption {\n    _id\n    columns {\n      _id\n      heading\n      width\n      __typename\n    }\n    rowCount\n    __typename\n  }\n  __typename\n}\n"
variables
:
{id: "6581a97a9944a8500087a37d"}
*
*
*
* */
