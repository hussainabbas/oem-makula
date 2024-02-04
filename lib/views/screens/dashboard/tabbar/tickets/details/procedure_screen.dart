// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/flutter_svg.dart';

// import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:makula_oem/helper/model/get_inventory_part_list_response.dart';
import 'package:makula_oem/helper/model/get_list_support_accounts_response.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';
import 'package:makula_oem/helper/model/signature_model.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/context_function.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/main.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/bottom_sheet_image_chooser_dialog.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/image_full_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/procedure_viewmodel.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/signature_procedure_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/procedure_provider.dart';
import 'package:makula_oem/views/widgets/custom_elevated_button.dart';
import 'package:makula_oem/views/widgets/dotter_border.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../../../../../../helper/model/get_current_user_details_model.dart';
import '../../../../../../helper/model/get_procedure_by_id_response.dart';
import '../../../../../../helper/model/safe_sign_s3_response.dart';
import '../../../../../../pubnub/message_provider.dart';
import '../../../../../../pubnub/pubnub_instance.dart';

class ProcedureScreen extends StatefulWidget {
  final String? templatesId;
  final String? ticketName;
  // PubnubInstance? pubnubInstance;
  // MessageProvider? messageProvider;

  ProcedureScreen(
      {super.key,
      required this.templatesId,
      required this.ticketName,
      // required this.pubnubInstance,
      // required this.messageProvider
      });

  @override
  State<ProcedureScreen> createState() => _ProcedureScreenState();
}

class _ProcedureScreenState extends State<ProcedureScreen> {
  GetInventoryPartListResponse? inventoryPartListResponse;
  GetListSupportAccountsResponse? listSupportAccountsResponse;
  CurrentUser? userValue;

  @override
  Widget build(BuildContext context) {
    Provider.of<ProcedureProvider>(context, listen: false).resetDirtyState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));

    getValueFromSP() async {
      userValue = (await appDatabase?.userDao.getCurrentUserDetailsFromDb())!;
      // widget.pubnubInstance = PubnubInstance(context);
      // widget.pubnubInstance
      //     ?.setSubscriptionChannel(userValue?.notificationChannel ?? "");
      // widget.messageProvider = MessageProvider(
      //     widget.pubnubInstance!, userValue?.notificationChannel ?? "");
    }

    // Extract the procedure from the templates
    // final ListOwnOemProcedureTemplates? templates = widget.templates;
    // final procedures = templates?.children ?? [];
    ListOwnOemProcedureTemplates? templates;
    List<ChildrenModel> procedures = [];

    observerGetProcedureByIdResponse(GetProcedureByIdResponse response) async {
      templates = response.getOwnOemProcedureById;
      procedures = templates?.children ?? [];
      console(
          "_observerGetProcedureByIdResponse => ${response.getOwnOemProcedureById?.state}");
      console(
          "_observerGetProcedureByIdResponse => ${response.getOwnOemProcedureById?.pdfUrl}");
      Provider.of<ProcedureProvider>(context, listen: false)
          .setMyProcedureRequest(templates);
      //templates = response.getOwnOemProcedureById;

      var savedTemplates = await appDatabase?.getProcedureByIdResponseDao
          .getProcedureById(widget.templatesId ?? "");

      if (savedTemplates == null) {
        console("_observerGetProcedureByIdResponse => savedTemplates == null");
        templates = response.getOwnOemProcedureById;
        procedures = templates?.children ?? [];
        await appDatabase?.getProcedureByIdResponseDao
            .insertListOwnOemProcedureTemplatesById(
                response.getOwnOemProcedureById!);
      } else {
        console("_observerGetProcedureByIdResponse => savedTemplates == else");
        var childrenModel = savedTemplates.children;
        var signatureModel = savedTemplates.signatures;
        List<SignatureRequestModel> signatureList = [];

        templates = savedTemplates;
        procedures = templates?.children ?? [];

        signatureModel?.forEach((element) {
          var model = SignatureRequestModel(
            id: element.sId,
            name: element.name,
            date: element.date,
            signature: element.signatureUrl,
          );
          signatureList.add(model);
        });
        var result = await ProcedureViewModel().saveAsDraftOemProcedure(
            widget.templatesId ?? "", childrenModel, signatureList);
        result.join(
            (failed) => {console("failed => ${failed.exception}")},
            (loaded) => {
                  console("loaded => ${loaded.data}"),
                },
            (loading) => {
                  console("loading => "),
                });
      }
    }

    getProcedureById(String procedureId) async {
      await getValueFromSP();
      await _getInventoryParts();
      var isConnected = await isConnectedToNetwork();

      if (isConnected) {
        if (context.mounted) context.showCustomDialog();
        var result = await ProcedureViewModel().getProcedureById(procedureId);
        if (context.mounted) Navigator.pop(context);
        result.join(
            (failed) => {console("failed => ${failed.exception}")},
            (loaded) => {
                  console("_getProcedureById -> Response => ${loaded.data}"),
                  observerGetProcedureByIdResponse(loaded.data),
                },
            (loading) => {
                  console("loading => "),
                });
      } else {
        templates = await appDatabase?.getProcedureByIdResponseDao
            .getProcedureById(procedureId);
        procedures = templates?.children ?? [];
      }
    }

    return Scaffold(
      body: FutureBuilder(
          future: getProcedureById(widget.templatesId ?? ""),
          builder: (context, projectSnap) {
            if (projectSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (projectSnap.hasError) {
              return const Center(child: Text(unexpectedError));
            } else {
              return WillPopScope(
                onWillPop: () async {
                  if (Provider.of<ProcedureProvider>(context, listen: false).isDirty && templates?.state != "FINALIZED") {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title:
                                const Text('Are you sure you want to leave?'),
                            content: const Text(
                                'By continuing without saving, you will lose all your work and updates. Are you sure you want to leave?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text('Cancel'),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(8)),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Provider.of<ProcedureProvider>(context,
                                            listen: false)
                                        .clearFieldValues();
                                    Provider.of<ProcedureProvider>(context,
                                            listen: false)
                                        .removeAllPartModels();
                                    Provider.of<ProcedureProvider>(context,
                                            listen: false)
                                        .clearImageFieldValue();
                                    Provider.of<ProcedureProvider>(context,
                                            listen: false)
                                        .clearTableDataRequestModel();
                                    Provider.of<ProcedureProvider>(context,
                                            listen: false)
                                        .clearSignature();

                                    Provider.of<ProcedureProvider>(context,
                                            listen: false)
                                        .clearSupportAccount();
                                    Provider.of<ProcedureProvider>(context,
                                            listen: false)
                                        .clearSupportAccountSid();
                                    Provider.of<ProcedureProvider>(context,
                                            listen: false)
                                        .resetDirtyState();
                                    Navigator.of(context).pop();
                                  },
                                  child: const TextView(
                                      text: "Yes, leave",
                                      textColor: Colors.white,
                                      textFontWeight: FontWeight.normal,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          );
                        });
                    return false;
                  }
                  else {
                    Provider.of<ProcedureProvider>(context, listen: false)
                        .clearFieldValues();
                    Provider.of<ProcedureProvider>(context, listen: false)
                        .removeAllPartModels();
                    Provider.of<ProcedureProvider>(context, listen: false)
                        .clearImageFieldValue();
                    Provider.of<ProcedureProvider>(context, listen: false)
                        .clearTableDataRequestModel();
                    Provider.of<ProcedureProvider>(context, listen: false)
                        .clearSignature();

                    Provider.of<ProcedureProvider>(context, listen: false)
                        .clearSupportAccount();
                    Provider.of<ProcedureProvider>(context, listen: false)
                        .clearSupportAccountSid();
                    Provider.of<ProcedureProvider>(context, listen: false)
                        .resetDirtyState();
                    Navigator.pop(context);
                    return true;
                  }
                },
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    centerTitle: false,
                    leading: GestureDetector(
                        onTap: () {
                          if (Provider.of<ProcedureProvider>(context,
                                      listen: false)
                                  .isDirty &&
                              templates?.state != "FINALIZED") {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Are you sure you want to leave?'),
                                    content: const Text(
                                        'By continuing without saving, you will lose all your work and updates. Are you sure you want to leave?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Provider.of<ProcedureProvider>(
                                                    context,
                                                    listen: false)
                                                .clearFieldValues();
                                            Provider.of<ProcedureProvider>(
                                                    context,
                                                    listen: false)
                                                .removeAllPartModels();
                                            Provider.of<ProcedureProvider>(
                                                    context,
                                                    listen: false)
                                                .clearImageFieldValue();
                                            Provider.of<ProcedureProvider>(
                                                    context,
                                                    listen: false)
                                                .clearTableDataRequestModel();
                                            Provider.of<ProcedureProvider>(
                                                    context,
                                                    listen: false)
                                                .clearSignature();

                                            Provider.of<ProcedureProvider>(
                                                    context,
                                                    listen: false)
                                                .clearSupportAccount();
                                            Provider.of<ProcedureProvider>(
                                                    context,
                                                    listen: false)
                                                .clearSupportAccountSid();
                                            Provider.of<ProcedureProvider>(
                                                    context,
                                                    listen: false)
                                                .resetDirtyState();
                                            Navigator.of(context).pop();
                                          },
                                          child: const TextView(
                                              text: "Yes, leave",
                                              textColor: Colors.white,
                                              textFontWeight: FontWeight.normal,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .clearFieldValues();
                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .removeAllPartModels();
                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .clearImageFieldValue();
                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .clearTableDataRequestModel();
                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .clearSignature();

                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .clearSupportAccount();
                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .clearSupportAccountSid();
                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .resetDirtyState();
                            Navigator.pop(context);
                          }
                        },
                        child: const Icon(Icons.arrow_back_ios)),
                    backgroundColor: Colors.grey.shade200,
                    title: TextView(
                        text: "${widget.ticketName} / ${templates?.name}",
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                          onTap: () async {
                                            console(
                                                "templates?.pdfUrl => ${templates?.pdfUrl}");
                                            if (templates?.state ==
                                                "FINALIZED") {
                                              launchURL(
                                                  templates?.pdfUrl ?? "");
                                            } else {
                                              context.showCustomDialog();
                                              var result =
                                                  await ProcedureViewModel()
                                                      .downloadProcedurePDF(
                                                          widget.templatesId ??
                                                              "",
                                                          generateRandomString());
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                              result.join(
                                                  (failed) => {
                                                        console(
                                                            "failed => ${failed.exception}")
                                                      },
                                                  (loaded) => {},
                                                  (loading) => {
                                                        console("loading => "),
                                                      });
                                            }
                                          },
                                          child: SvgPicture.asset(
                                              "assets/images/ghost_button.svg")),
                                      Container(
                                          decoration: BoxDecoration(
                                              color: templates?.state !=
                                                      "FINALIZED"
                                                  ? lightGray
                                                  : closedContainerColor,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 4, 4, 5),
                                          child: TextView(
                                              align: TextAlign.center,
                                              text: templates?.state
                                                      ?.replaceAll("_", " ") ??
                                                  "",
                                              textColor: templates?.state !=
                                                      "FINALIZED"
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
                                  for (var entry in procedures.asMap().entries)
                                    //for (var procedure in procedures)
                                    FieldWidget(
                                      fieldData: entry.value,
                                      isBorderShowing: true,
                                      index: entry.key,
                                      parentIndex: -1,
                                      isAChildren: false,
                                      userValue: userValue,
                                      procedureId: widget.templatesId ?? "",
                                      listSupportAccountsResponse:
                                          listSupportAccountsResponse,
                                      isEditable: templates?.state !=
                                              "FINALIZED" &&
                                          ((Provider.of<ProcedureProvider>(
                                                          context,
                                                          listen: false)
                                                      .signatureModel
                                                      ?.isEmpty ??
                                                  false) ||
                                              (Provider.of<ProcedureProvider>(
                                                          context,
                                                          listen: false)
                                                      .signatureModel?[0]
                                                      ?.signature ==
                                                  null)),
                                      inventoryPartListResponse:
                                          inventoryPartListResponse,
                                    ),
                                  const SizedBox(height: 16),
                                  //SIGNATURE

                                  if (templates?.signatures?.isNotEmpty == true)
                                    SignatureWidget(
                                      signatureModel: templates?.signatures,
                                      isEditable:
                                          templates?.state != "FINALIZED",
                                      currentUser: userValue,
                                      context: context,
                                      procedureId: widget.templatesId ?? "",
                                    ),
                                  // ChangeNotifierProvider.value(
                                  // value: Provider.of<ProcedureProvider>(
                                  //     context,
                                  //     listen: true),
                                  // child: SignatureWidget(
                                  //   signatureModel: templates?.signatures,
                                  //   isEditable:
                                  //       templates?.state != "FINALIZED",
                                  //       currentUser: userValue,
                                  //       procedureId: widget.templatesId ?? "",
                                  // ),
                                  //),
                                ],
                              ),
                            ),
                          ),
                          if (templates?.state != "FINALIZED")
                            ActionButtons(
                              templatesId: widget.templatesId ?? "",
                              refreshCallback: () {
                                refreshScreen(
                                    context, widget.templatesId ?? "");
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }

  _getInventoryParts() async {
    var isConnected = await isConnectedToNetwork();
    if (isConnected) {
      var result = await ProcedureViewModel().getInventoryPartList();
      result.join(
          (failed) => {console("failed => ${failed.exception}")},
          (loaded) => {
                _observerGetInventoryParts(loaded.data),
              },
          (loading) => {
                console("loading => "),
              });
    }
  }

  _observerGetInventoryParts(GetInventoryPartListResponse response) async {
    console(
        "_observerGetInventoryParts => ${response.listOwnOemInventoryPart?.parts?.length}");
    inventoryPartListResponse = response;

    await _getListSupportAccounts();
  }

  _getListSupportAccounts() async {
    var isConnected = await isConnectedToNetwork();
    if (isConnected) {
      var result = await ProcedureViewModel().getListSupportAccounts();
      result.join(
          (failed) => {console("failed => ${failed.exception}")},
          (loaded) => {
                _observerGetListSupportAccounts(loaded.data),
              },
          (loading) => {
                console("loading => "),
              });
    }
  }

  _observerGetListSupportAccounts(GetListSupportAccountsResponse response) {
    console(
        "_observerGetListSupportAccounts => ${response.listOwnOemSupportAccounts?.length}");
    listSupportAccountsResponse = response;
  }

  void refreshScreen(BuildContext context, String templateId) {
    Future.delayed(const Duration(seconds: 1), () async {
      var templates = await appDatabase?.getProcedureByIdResponseDao
          .getProcedureById(templateId);

      var childrenModel = Provider.of<ProcedureProvider>(context, listen: false)
          .myProcedureRequest
          ?.children;
      var signatureRequestModel =
          Provider.of<ProcedureProvider>(context, listen: false).signatureModel;

      List<SignatureModel> signatureList = [];

      signatureRequestModel?.forEach((element) {
        var model = SignatureModel(
          sId: element.id,
          name: element.name,
          date: element.date,
          signatureUrl: element.signature,
        );
        signatureList.add(model);
      });

      templates?.children = childrenModel;
      templates?.signatures = signatureList;

      await appDatabase?.getProcedureByIdResponseDao
          .updateListOwnOemProcedureTemplates(templates!);
      setState(() {
        // Your logic for refreshing the screen goes here
      });
    });
  }
}

class SignatureWidget extends StatelessWidget {
  final List<SignatureModel>? signatureModel;
  final bool isEditable;
  final CurrentUser? currentUser;
  final String procedureId;
  final BuildContext context;

  SignatureWidget(
      {super.key,
      required this.signatureModel,
      required this.isEditable,
      required this.context,
      required this.currentUser,
      required this.procedureId}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Provider.of<ProcedureProvider>(context, listen: false).clearSignature();
      signatureModel?.forEach((element) {
        var model = SignatureRequestModel(
            name: element.name,
            date: element.date,
            id: element.sId.toString(),
            signature: element.signatureUrl);

        if (Provider.of<ProcedureProvider>(context, listen: false)
                .signatureModel
                ?.contains(model) ==
            false) {
          Provider.of<ProcedureProvider>(context, listen: false)
              .signatureModel
              ?.add(model);
        }

        console(
            "SignatureWidget => ${Provider.of<ProcedureProvider>(context, listen: false).signatureModel?.length}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final formStateProvider =
        Provider.of<ProcedureProvider>(context, listen: false);

    DateTime? selectedDate;
    return ChangeNotifierProvider.value(
      value: Provider.of<ProcedureProvider>(context, listen: true),
      child: Container(
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
                itemCount: signatureModel?.length ?? 0,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  bool? idExists =
                      Provider.of<ProcedureProvider>(context, listen: false)
                          .signatureModel
                          ?.any((signature) =>
                              signature.id == signatureModel?[index].sId);
                  if (idExists == false) {
                    Provider.of<ProcedureProvider>(context, listen: false)
                        .signatureModel
                        ?.add(SignatureRequestModel(
                            id: signatureModel?[index].sId));
                  }

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
                      GestureDetector(
                        onTap: () async {
                          if (formStateProvider.isValid && isEditable) {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null &&
                                pickedDate != selectedDate) {
                              if (context.mounted) {
                                var selectedSignatureModel =
                                    Provider.of<ProcedureProvider>(context,
                                            listen: false)
                                        .signatureModel?[index];
                                var model = SignatureRequestModel(
                                    name: selectedSignatureModel?.name,
                                    date:
                                        "${DateFormat("yyyy-MM-dd'T'hh:mm:ss.SSS'Z").format(pickedDate)}Z",
                                    id: signatureModel?[index].sId.toString(),
                                    signature:
                                        selectedSignatureModel?.signature);

                                Provider.of<ProcedureProvider>(context,
                                        listen: false)
                                    .updateSignature(model, index);

                                console(
                                    "SignatureRequestModel => ${Provider.of<ProcedureProvider>(context, listen: false).signatureModel?[index].date}");
                                // Save the value to the state
                                // final formStateProvider =
                                // Provider.of<ProcedureProvider>(context, listen: false);
                                // formStateProvider.setFieldValue(name, DateFormat('dd/MM/yyyy').format(pickedDate));
                              }
                            }
                          }
                        },
                        child: Container(
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
                                    text: Provider.of<ProcedureProvider>(
                                                context,
                                                listen: true)
                                            .signatureModel?[index]
                                            .date
                                            ?.convertStringDDMMYYYHHMMSSDateToEMMMDDYYYY() ??
                                        "Select Date",
                                    textColor: textColorLight,
                                    textFontWeight: FontWeight.normal,
                                    fontSize: 12),
                                Icon(
                                  Icons.calendar_month,
                                  color: textColorLight,
                                )
                              ],
                            )),
                      ),
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
                          enabled: formStateProvider.isValid && isEditable,
                          // Use the field name as the key
                          initialValue: Provider.of<ProcedureProvider>(context,
                                  listen: false)
                              .signatureModel?[index]
                              .name,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Name",
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            return null;
                          },
                          onChanged: (value) {
                            // final formStateProvider =
                            //     Provider.of<ProcedureProvider>(context,
                            //         listen: false);
                            // formStateProvider.setFieldValue(
                            //     "Signature", value);

                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .signatureModel?[index]
                                .name = value;
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
                          if (formStateProvider.isValid && isEditable) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SignatureProcedureScreen(
                                        index: index,
                                        currentUser: currentUser,
                                        procedureId: procedureId,
                                      )),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 200,
                          width: context.fullWidth(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Provider.of<ProcedureProvider>(context,
                                          listen: false)
                                      .signatureModel?[index]
                                      .signature ==
                                  null
                              ? TextView(
                                  text: "Sign here",
                                  textColor: textColorLight,
                                  textFontWeight: FontWeight.normal,
                                  fontSize: 12)
                              : CachedNetworkImage(
                                  placeholder: (context, url) => const Padding(
                                    padding: EdgeInsets.zero,
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                  imageUrl: Provider.of<ProcedureProvider>(
                                              context,
                                              listen: false)
                                          .signatureModel?[index]
                                          .signature ??
                                      "",
                                ),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 30,
                  );
                },
              ),
            ],
          )),
    );
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

class ActionButtons extends StatefulWidget {
  final VoidCallback refreshCallback;
  final String templatesId;

  const ActionButtons(
      {super.key, required this.refreshCallback, required this.templatesId});

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  @override
  Widget build(BuildContext context) {
    final formStateProvider =
        Provider.of<ProcedureProvider>(context, listen: false);
    var isValid = false;
    if (formStateProvider.isValid) {
      isValid = true;
    }

    if (Provider.of<ProcedureProvider>(context, listen: false)
        .fieldValues
        .isEmpty) {
      isValid = true;
    }

    if (Provider.of<ProcedureProvider>(context, listen: false)
            .signatureModel
            ?.isNotEmpty ==
        true) {
      if (Provider.of<ProcedureProvider>(context, listen: false)
              .signatureModel?[0]
              .signature !=
          null) {
        isValid = true;
      } else {
        isValid = false;
      }
    } else {
      isValid = true;
    }

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
                    textColor:
                        formStateProvider.isDirty ? primaryColor : Colors.white,
                    borderRadius: 8,
                    isValid: formStateProvider.isDirty,
                    title: "Save as Draft",
                    fontSize: 14,
                    onPressed: () async {
                      var isConnected = await isConnectedToNetwork();
                      if (isConnected && context.mounted) {
                        context.showCustomDialog();
                        var sId = Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .myProcedureRequest
                                ?.sId ??
                            "";
                        var childrenModel = Provider.of<ProcedureProvider>(
                                context,
                                listen: false)
                            .myProcedureRequest
                            ?.children;
                        var signatureRequestModel =
                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .signatureModel;
                        var result = await ProcedureViewModel()
                            .saveAsDraftOemProcedure(
                                sId, childrenModel, signatureRequestModel);
                        if (context.mounted) Navigator.pop(context);
                        result.join(
                            (failed) =>
                                {console("failed => ${failed.exception}")},
                            (loaded) => {
                                  console("loaded => ${loaded.data}"),
                                  widget.refreshCallback(),
                                  context.showSuccessSnackBar(
                                      "Your changes are saved successfully")
                                },
                            (loading) => {
                                  console("loading => "),
                                });
                      } else {
                        widget.refreshCallback();
                        //templates?.signatures = signatureRequestModel;
                      }
                    })),
            const SizedBox(
              width: 16,
            ),
            Expanded(
                child: CustomElevatedButton(
                    textColor: Colors.white,
                    borderRadius: 8,
                    fontSize: 14,
                    isValid: isValid,
                    title: "Finalize",
                    onPressed: () async {
                      var isConnected = await isConnectedToNetwork();
                      if (isConnected && context.mounted) {
                        context.showCustomDialog();
                        var sId = Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .myProcedureRequest
                                ?.sId ??
                            "";
                        var childrenModel = Provider.of<ProcedureProvider>(
                                context,
                                listen: false)
                            .myProcedureRequest
                            ?.children;
                        var signatureRequestModel =
                            Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .signatureModel;
                        var result = await ProcedureViewModel()
                            .finalizeOemProcedure(
                                sId, childrenModel, signatureRequestModel);
                        if (context.mounted) Navigator.pop(context);
                        result.join(
                            (failed) =>
                                {console("failed => ${failed.exception}")},
                            (loaded) => {
                                  console("loaded => ${loaded.data}"),
                                  Navigator.pop(context),
                                  finalize(
                                      formStateProvider.fieldValues, context)
                                },
                            (loading) => {
                                  console("loading => "),
                                });
                      }
                    })),
          ],
        ),
      ),
    );
  }

  void finalize(Map<String, dynamic> fieldValues, BuildContext context) {
    final formStateProvider =
        Provider.of<ProcedureProvider>(context, listen: false);
    console('Finalizing with values: $fieldValues');
    console('Finalizing with values: ${formStateProvider.isValid}');
    setState(() {});
  }
}

class FieldWidget extends StatelessWidget {
  final ChildrenModel fieldData;
  final bool isBorderShowing;
  final bool isEditable;
  final GetInventoryPartListResponse? inventoryPartListResponse;
  final GetListSupportAccountsResponse? listSupportAccountsResponse;
  final int index;
  final int parentIndex;
  final bool isAChildren;
  final CurrentUser? userValue;
  final String procedureId;

  const FieldWidget(
      {super.key,
      required this.fieldData,
      required this.isBorderShowing,
      required this.isEditable,
      required this.index,
      required this.parentIndex,
      required this.userValue,
      required this.isAChildren,
      required this.procedureId,
      required this.listSupportAccountsResponse,
      required this.inventoryPartListResponse});

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
          isEditable: isEditable,
          index: index,
          parentIndex: parentIndex,
          isAChildren: isAChildren,
        );
      case 'TEXT_AREA_FIELD':
        return NumberTextField(
            name: name,
            fieldData: fieldData,
            isRequired: isRequired,
            keyboardType: TextInputType.text,
            description: description,
            isBorderShowing: isBorderShowing,
            isEditable: isEditable,
            index: index,
            isMultiline: true,
            parentIndex: parentIndex,
            isAChildren: isAChildren,
            context: context);
      case 'NUMBER_FIELD':
        return NumberTextField(
            name: name,
            fieldData: fieldData,
            isRequired: isRequired,
            description: description,
            isBorderShowing: isBorderShowing,
            keyboardType: TextInputType.number,
            isEditable: isEditable,
            index: index,
            isMultiline: false,
            parentIndex: parentIndex,
            isAChildren: isAChildren,
            context: context);
      case 'DATE_FIELD':
        return DatePickerWidget(
            name: name,
            fieldData: fieldData,
            isRequired: isRequired,
            description: description,
            isEditable: isEditable,
            index: index,
            parentIndex: parentIndex,
            isAChildren: isAChildren,
            context: context);
      case 'SECTION':
        return SectionWidget(
          sectionData: fieldData,
          isEditable: isEditable,
          parentIndex: index,
          userValue: userValue,
          procedureId: procedureId,
          inventoryPartListResponse: inventoryPartListResponse,
          listSupportAccountsResponse: listSupportAccountsResponse,
        );
      case 'CHECKLIST_FIELD':
        return ChecklistFieldWidget(
          fieldData: fieldData,
          context: context,
          index: index,
          parentIndex: parentIndex,
          isAChildren: isAChildren,
          isEditable: isEditable,
        );
      case 'CHECKBOX_FIELD':
        return CheckboxFieldWidget(
          fieldData: fieldData,
          context: context,
          index: index,
          parentIndex: parentIndex,
          isAChildren: isAChildren,
          isEditable: isEditable,
        );
      case 'IMAGE_UPLOADER_FIELD':
        return ImageUploaderWidget(
            name: fieldData.name ?? "",
            fieldData: fieldData,
            isRequired: fieldData.isRequired ?? false,
            description: fieldData.description ?? "",
            isEditable: isEditable,
            index: index,
            userValue: userValue,
            parentIndex: parentIndex,
            isAChildren: isAChildren,
            procedureId: procedureId,
            context: context);
      case 'PARTS_FIELD':
        return PartsFieldWidget(
            fieldData: fieldData,
            inventoryPartListResponse: inventoryPartListResponse,
            name: fieldData.name ?? "",
            isRequired: fieldData.isRequired ?? false,
            description: fieldData.description ?? "",
            isEditable: isEditable,
            index: index,
            parentIndex: parentIndex,
            isAChildren: isAChildren,
            context: context);
      case 'SINGLE_SELECT_FIELD':
        return SingleSelectFieldWidget(
            name: fieldData.name ?? "",
            isRequired: fieldData.isRequired ?? false,
            description: fieldData.description ?? "",
            fieldData: fieldData,
            isEditable: isEditable,
            index: index,
            parentIndex: parentIndex,
            isAChildren: isAChildren,
            context: context);
      case 'TABLE_FIELD':
        return TableFieldWidget(
          fieldData: fieldData,
          context: context,
          isEditable: isEditable,
          index: index,
          parentIndex: parentIndex,
          isAChildren: isAChildren,
        );
      case 'MEMBER_FIELD':
        return MemberFieldWidget(
          name: fieldData.name ?? "",
          fieldData: fieldData,
          context: context,
          isEditable: isEditable,
          index: index,
          parentIndex: parentIndex,
          isAChildren: isAChildren,
          listSupportAccountsResponse: listSupportAccountsResponse,
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
  final bool isEditable;
  final int index;
  final int parentIndex;
  final bool isAChildren;

  TableFieldWidget(
      {super.key,
      required this.fieldData,
      required this.context,
      required this.index,
      required this.parentIndex,
      required this.isAChildren,
      required this.isEditable}) {
    if (fieldData.isRequired == true) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
      });
    }
  }

  @override
  _TableFieldWidgetState createState() => _TableFieldWidgetState();
}

class _TableFieldWidgetState extends State<TableFieldWidget> {
  List<List<TextEditingController>> rows = [];
  late BuildContext _context;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    console("TableFieldWidget => ${widget.fieldData.value}");

    if (widget.fieldData.value != null) {
      var dataList = widget.fieldData.value;
      Provider.of<ProcedureProvider>(_context, listen: false)
          .clearTableDataRequestModel();
      for (var dataMap in dataList) {
        dataMap.forEach((key, value) {
          Provider.of<ProcedureProvider>(_context, listen: false)
              .setTableDataRequestModel(ColumnsModel(sId: key, value: value, heading: ""));
        });
        List<TextEditingController> newRow = List.generate(
          widget.fieldData.tableOption?.columns?.length ?? 0,
          (index) => TextEditingController(),
        );
        rows.add(newRow);
        setState(() {});
      }
    }

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
                                  if (widget.isEditable) {
                                    deleteRow(mainIndex);
                                  }
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
                          var tableRequestModel =
                              Provider.of<ProcedureProvider>(_context,
                                      listen: false)
                                  .tableDataRequest;

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
                                    enabled: widget.isEditable,
                                    //controller: rows[mainIndex][childIndex],
                                    initialValue: "",
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

                                      Provider.of<ProcedureProvider>(context,
                                              listen: false)
                                          .tableDataRequest?[mainIndex]
                                          .sId = columnItem?.sId;
                                      Provider.of<ProcedureProvider>(context,
                                              listen: false)
                                          .tableDataRequest?[mainIndex]
                                          .value = value;

                                      if (widget.isAChildren) {
                                        Provider.of<ProcedureProvider>(context,
                                                    listen: false)
                                                .myProcedureRequest
                                                ?.children?[widget.parentIndex]
                                                .children?[widget.index]
                                                .value =
                                            Provider.of<ProcedureProvider>(
                                                    context,
                                                    listen: false)
                                                .tableDataRequest;
                                      } else {
                                        Provider.of<ProcedureProvider>(context,
                                                    listen: false)
                                                .myProcedureRequest
                                                ?.children?[widget.index]
                                                .value =
                                            Provider.of<ProcedureProvider>(
                                                    context,
                                                    listen: false)
                                                .tableDataRequest;
                                      }
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
                  if (widget.isEditable) {
                    addRow();
                  }
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

  void addRow() {
    // Create a new row with empty controllers
    List<TextEditingController> newRow = List.generate(
      widget.fieldData.tableOption?.columns?.length ?? 0,
      (index) => TextEditingController(),
    );

    Provider.of<ProcedureProvider>(_context, listen: false)
        .setTableDataRequestModel(ColumnsModel(sId: "0", value: "", heading: ""));
    // Add the new row to the list
    setState(() {
      rows.add(newRow);
    });
  }

  void deleteRow(int rowIndex) {
    // Remove the selected row
    Provider.of<ProcedureProvider>(_context, listen: false)
        .deleteTableDataRequestModel(rowIndex);
    setState(() {
      rows.removeAt(rowIndex);
    });
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
  final bool isEditable;
  final int index;
  final int parentIndex;
  final bool isAChildren;
  final CurrentUser? userValue;
  final String procedureId;

  ImageUploaderWidget(
      {super.key,
      required this.name,
      required this.fieldData,
      required this.isRequired,
      required this.description,
      required this.context,
      required this.index,
      required this.userValue,
      required this.parentIndex,
      required this.isAChildren,
      required this.procedureId,
      required this.isEditable}) {
    Future.delayed(const Duration(milliseconds: 0), () {
      final formStateProvider =
          Provider.of<ProcedureProvider>(context, listen: false);

      if (fieldData.isRequired == true) {
        formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
      }
      formStateProvider.clearImageRequestModel();
      if (fieldData.value != null) {
        formStateProvider.clearImageRequestModel();
        Provider.of<ProcedureProvider>(context, listen: false)
            .clearImageFieldValue();
        var value = fieldData.value as List;
        for (var element in value) {
          if (element["url"] != null) {
            console("ImageUploaderWidget  URL=> ${element["url"]}");
            var imageRequestModel = ImageRequestModel(
              name: element["name"],
              size: element["size"],
              type: element["type"],
              url: element["url"],
            );
            formStateProvider.setImageRequestModel(imageRequestModel);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    console("ImageUploaderWidget => ${fieldData.value}");
    final formStateProvider =
        Provider.of<ProcedureProvider>(context, listen: false);

    return ChangeNotifierProvider.value(
      value: Provider.of<ProcedureProvider>(context, listen: true),
      child: SizedBox(
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
                if (isEditable) {
                  BottomSheetImageChooserModal.show(
                      context,
                      fieldData.name ?? "",
                      index,
                      parentIndex,
                      isAChildren,
                      userValue,
                      procedureId);

                  // formStateProvider.setImageFieldValue(
                  //     fieldData.name ?? "", "randomString");
                }
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
              height: 10,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: formStateProvider.imageRequestModel?.length ?? 0,
              itemBuilder: (context, index) {
                var item = formStateProvider.imageRequestModel?[index];
                var file = File(item?.url ?? "");
                String fileName = basename(file.path);
                String fileExtension = extension(file.path).replaceAll(".", "");
                console('Picked File Extension: $fileExtension');

                return ListTile(
                  // leading: SizedBox(
                  //   height: 24,
                  //   width: 24,
                  //   child: Image.file(File(item ?? "")),
                  // ),
                  //
                  leading: SizedBox(
                    height: 24,
                    width: 24,
                    child: CachedNetworkImage(
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.zero,
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      imageUrl: file.path,
                    ),
                  ),

                  title: TextView(
                      text: fileName ?? "",
                      textColor: textColorLight,
                      textFontWeight: FontWeight.normal,
                      fontSize: 12),
                  subtitle: TextView(
                      text: "image/$fileExtension",
                      textColor: textColorLight,
                      textFontWeight: FontWeight.normal,
                      fontSize: 10),
                  trailing: GestureDetector(
                    onTap: () {
                      formStateProvider.deleteImageRequestModel(item!);
                    },
                    child: Icon(
                      Icons.delete,
                      color: textColorLight,
                    ),
                  ),
                );
              },
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
  final bool isEditable;
  final GetInventoryPartListResponse? inventoryPartListResponse;
  final int index;
  final int parentIndex;
  final bool isAChildren;

  PartsFieldWidget(
      {super.key,
      required this.name,
      required this.fieldData,
      required this.isRequired,
      required this.description,
      required this.inventoryPartListResponse,
      required this.context,
      required this.index,
      required this.parentIndex,
      required this.isAChildren,
      required this.isEditable}) {
    Future.delayed(const Duration(milliseconds: 0), () {
      final formStateProvider =
          Provider.of<ProcedureProvider>(context, listen: false);
      if (fieldData.isRequired == true) {
        formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
        console("PartsFieldWidget value => ${fieldData.value}");
      }
      if (fieldData.value != null) {
        var value = fieldData.value as List;
        Set<String> stringSet = Set.from(value);
        Provider.of<ProcedureProvider>(context, listen: false).clearPartModel();
        Provider.of<ProcedureProvider>(context, listen: false)
            .clearPartModelSId();
        for (var element in value) {
          console("PartsFieldWidget element => $element");

          Provider.of<ProcedureProvider>(context, listen: false)
              .addPartModelSId(element);
        }
        List<PartsModel>? matchingParts = inventoryPartListResponse
            ?.listOwnOemInventoryPart?.parts
            ?.where((part) => stringSet.contains(part.sId))
            .toList();
        console("PartsFieldWidget  matchingParts => ${matchingParts?.length}");

        matchingParts?.forEach((element) {
          Provider.of<ProcedureProvider>(context, listen: false)
              .addPartModel(element);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formStateProvider =
        Provider.of<ProcedureProvider>(context, listen: false);

    return ChangeNotifierProvider.value(
      value: Provider.of<ProcedureProvider>(context, listen: true),
      child: SizedBox(
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
            DropdownSearch<PartsModel>(
              items:
                  inventoryPartListResponse?.listOwnOemInventoryPart?.parts ??
                      [],
              selectedItem: null,
              enabled: isEditable,
              itemAsString: (PartsModel? u) =>
                  u == null ? "" : u.name.toString(),
              onChanged: (PartsModel? data) => {
                Provider.of<ProcedureProvider>(context, listen: false)
                    .addPartModel(data),
                Provider.of<ProcedureProvider>(context, listen: false)
                    .addPartModelSId(data?.sId),
                Provider.of<ProcedureProvider>(context, listen: false)
                    .setFieldValue(name, data?.sId),
                if (isAChildren)
                  {
                    Provider.of<ProcedureProvider>(context, listen: false)
                            .myProcedureRequest
                            ?.children?[parentIndex]
                            .children?[index]
                            .value =
                        Provider.of<ProcedureProvider>(context, listen: false)
                            .selectedPartsSIdList,
                  }
                else
                  {
                    Provider.of<ProcedureProvider>(context, listen: false)
                            .myProcedureRequest
                            ?.children?[index]
                            .value =
                        Provider.of<ProcedureProvider>(context, listen: false)
                            .selectedPartsSIdList,
                  }
              },
              popupProps: PopupProps.bottomSheet(
                isFilterOnline: true,
                showSearchBox: true,
                showSelectedItems: false,
                searchFieldProps: TextFieldProps(
                  controller: TextEditingController(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search...',
                  ),
                ),
              ),
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
            ListView.separated(
              itemCount: formStateProvider.selectedPartsList?.length ?? 0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = formStateProvider.selectedPartsList?[index];
                return ListTile(
                  leading: SizedBox(
                    height: 24,
                    width: 24,
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        placeholder: (context, url) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            ),
                        errorWidget: (context, url, error) =>
                            defaultImageBigInventory(context),
                        imageUrl: item?.image ?? ""),
                  ),
                  title: TextView(
                      text: item?.name ?? "",
                      textColor: textColorLight,
                      textFontWeight: FontWeight.normal,
                      fontSize: 12),
                  subtitle: TextView(
                      text: item?.description ?? "",
                      textColor: textColorLight,
                      textFontWeight: FontWeight.normal,
                      fontSize: 10),
                  trailing: GestureDetector(
                    onTap: () {
                      formStateProvider.removePartModel(item);
                      formStateProvider.removePartModelSId(item?.sId);
                    },
                    child: Icon(
                      Icons.delete,
                      color: textColorLight,
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
            AttachmentWidget(fieldData: fieldData),
            const SizedBox(
              height: 8,
            ),
            const Divider()
          ],
        ),
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
  final bool isEditable;
  final int index;
  final int parentIndex;
  final bool isAChildren;

  SingleSelectFieldWidget(
      {super.key,
      required this.name,
      required this.isRequired,
      required this.description,
      required this.fieldData,
      required this.context,
      required this.index,
      required this.parentIndex,
      required this.isAChildren,
      required this.isEditable}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      final formStateProvider =
          Provider.of<ProcedureProvider>(context, listen: false);
      if (fieldData.isRequired == true) {
        formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
      }
      if (fieldData.value != null) {
        var value = fieldData.value as String;
        Provider.of<ProcedureProvider>(context)
            .setFieldValue(fieldData.name ?? "", value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = fieldData.options ?? [];

    console("SingleSelectFieldWidget => ${fieldData.value}");

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
                            option.sId
                        ? option
                        : null,
                    onChanged: (OptionsModel? value) {
                      if (isEditable) {
                        final formStateProvider =
                            Provider.of<ProcedureProvider>(context,
                                listen: false);

                        // Save only the name in fieldValues
                        formStateProvider.setFieldValue(name, option.sId);

                        if (isAChildren) {
                          Provider.of<ProcedureProvider>(context, listen: false)
                              .myProcedureRequest
                              ?.children?[parentIndex]
                              .children?[index]
                              .value = option.sId;
                        } else {
                          Provider.of<ProcedureProvider>(context, listen: false)
                              .myProcedureRequest
                              ?.children?[index]
                              .value = option.sId;
                        }
                      }
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
  final GetListSupportAccountsResponse? listSupportAccountsResponse;
  final bool isEditable;
  final int index;
  final int parentIndex;
  final bool isAChildren;

  MemberFieldWidget(
      {super.key,
      required this.name,
      required this.fieldData,
      required this.isRequired,
      required this.description,
      required this.context,
      required this.index,
      required this.parentIndex,
      required this.isAChildren,
      required this.listSupportAccountsResponse,
      required this.isEditable}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      final formStateProvider =
          Provider.of<ProcedureProvider>(context, listen: false);
      if (fieldData.isRequired == true) {
        formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
      }
      if (fieldData.value != null) {
        Provider.of<ProcedureProvider>(context, listen: false)
            .clearSupportAccountSid();
        Provider.of<ProcedureProvider>(context, listen: false)
            .clearSupportAccount();
        var value = fieldData.value as List;
        Set<String> stringSet = Set.from(value);

        for (var element in value) {
          Provider.of<ProcedureProvider>(context, listen: false)
              .addSupportAccountSid(element);
        }
        var matchingAccounts = listSupportAccountsResponse
            ?.listOwnOemSupportAccounts
            ?.where((part) => stringSet.contains(part.sId))
            .toList();
        console(
            "MemberFieldWidget  MemberFieldWidget => ${matchingAccounts?.length}");

        matchingAccounts?.forEach((element) {
          Provider.of<ProcedureProvider>(context, listen: false)
              .addSupportAccount(element);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formStateProvider =
        Provider.of<ProcedureProvider>(context, listen: false);
    console("MemberFieldWidget => ${fieldData.value}");
    return ChangeNotifierProvider.value(
      value: Provider.of<ProcedureProvider>(context, listen: true),
      child: SizedBox(
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
            DropdownSearch<ListSupportAccounts>(
              // popupProps: const PopupProps.bottomSheet(),
              // dropdownSearchDecoration: InputDecoration(labelText: "Name"),
              items:
                  listSupportAccountsResponse?.listOwnOemSupportAccounts ?? [],
              selectedItem: null,
              enabled: isEditable,
              itemAsString: (ListSupportAccounts? u) =>
                  u == null ? "" : u.name.toString(),
              onChanged: (ListSupportAccounts? data) => {
                Provider.of<ProcedureProvider>(context, listen: false)
                    .addSupportAccount(data),
                Provider.of<ProcedureProvider>(context, listen: false)
                    .addSupportAccountSid(data?.sId),
                Provider.of<ProcedureProvider>(context, listen: false)
                    .setFieldValue(name, data?.sId),
                if (isAChildren)
                  {
                    Provider.of<ProcedureProvider>(context, listen: false)
                            .myProcedureRequest
                            ?.children?[parentIndex]
                            .children?[index]
                            .value =
                        Provider.of<ProcedureProvider>(context, listen: false)
                            .selectedSupportAccountSIdList,
                  }
                else
                  {
                    Provider.of<ProcedureProvider>(context, listen: false)
                            .myProcedureRequest
                            ?.children?[index]
                            .value =
                        Provider.of<ProcedureProvider>(context, listen: false)
                            .selectedSupportAccountSIdList,
                  }
              },
              popupProps: PopupProps.bottomSheet(
                isFilterOnline: true,
                showSearchBox: true,
                showSelectedItems: false,
                searchFieldProps: TextFieldProps(
                  controller: TextEditingController(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search...',
                  ),
                ),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: "Choose Member",
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
            ListView.separated(
              itemCount: formStateProvider.selectedSupportAccount?.length ?? 0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = formStateProvider.selectedSupportAccount?[index];
                return ListTile(
                  leading: SizedBox(
                    height: 24,
                    width: 24,
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        placeholder: (context, url) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            ),
                        errorWidget: (context, url, error) =>
                            defaultImageBig(context),
                        imageUrl: getInitials(item?.name ?? "")),
                  ),
                  title: TextView(
                      text: item?.name ?? "",
                      textColor: textColorLight,
                      textFontWeight: FontWeight.normal,
                      fontSize: 12),
                  trailing: GestureDetector(
                    onTap: () {
                      formStateProvider.removeSupportAccount(item);
                      formStateProvider.removePartModelSId(item?.sId);
                    },
                    child: Icon(
                      Icons.delete,
                      color: textColorLight,
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
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
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  final String name;
  final bool isRequired;
  final BuildContext context;
  final ChildrenModel fieldData;
  final bool isEditable;
  final int index;
  final int parentIndex;
  final bool isAChildren;

  TextWidget(
      {super.key,
      required this.name,
      required this.isRequired,
      required this.fieldData,
      required this.context,
      required this.index,
      required this.parentIndex,
      required this.isAChildren,
      required this.isEditable}) {
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

// class TextFieldWidget extends StatelessWidget {
//   final String name;
//   final String description;
//   final bool isRequired;
//   final bool isBorderShowing;
//   final TextInputType keyboardType;
//   final BuildContext context;
//   final ChildrenModel fieldData;
//   final bool isEditable;
//   final int index;
//   final int parentIndex;
//   final bool isAChildren;
//   final bool isMultiline;
//
//   TextFieldWidget(
//       {super.key,
//       required this.name,
//       required this.description,
//       required this.isBorderShowing,
//       required this.isRequired,
//       required this.context,
//       required this.fieldData,
//       required this.keyboardType,
//       required this.index,
//       required this.parentIndex,
//       required this.isAChildren,
//       required this.isMultiline,
//       required this.isEditable}) {
//     Future.delayed(const Duration(milliseconds: 0), () {
//       final formStateProvider =
//           Provider.of<ProcedureProvider>(context, listen: false);
//       if (fieldData.isRequired == true) {
//         formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
//       }
//       var value = "";
//       console("TextFieldWidget VALUE => ${fieldData.value}");
//       if (fieldData.value is List) {
//         console("TextFieldWidget VALUE List => ${fieldData.value}");
//         for (int i = 0; i < fieldData.value.length; i++) {
//           var type = fieldData.value[i]['type'];
//           if (type == "paragraph") {
//             List<dynamic> children = fieldData.value[i]['children'];
//
//             for (int j = 0; j < children.length; j++) {
//               var textValue = children[j]['text'];
//
//               value = "$value $textValue";
//
//               if (j == children.length - 1) {
//                 value += "\n"; // Add newline
//               }
//             }
//           } else if (type == 'bulleted-list') {
//             List<dynamic> listItems = fieldData.value[i]['children'];
//
//             for (int k = 0; k < listItems.length; k++) {
//               var listItem = listItems[k];
//               var listItemType = listItem['type'];
//               var listItemChildren = listItem['children'];
//
//               for (int l = 0; l < listItemChildren.length; l++) {
//                 var listItemText = listItemChildren[l]['text'];
//                 value = "$value • $listItemText";
//
//                 if (l == listItemChildren.length - 1) {
//                   value += "\n"; // Add newline
//                 }
//               }
//             }
//           } else if (type == 'numbered-list') {
//             List<dynamic> listItems = fieldData.value[i]['children'];
//
//             for (int k = 0; k < listItems.length; k++) {
//               var listItem = listItems[k];
//               var listItemType = listItem['type'];
//               var listItemChildren = listItem['children'];
//
//               for (int l = 0; l < listItemChildren.length; l++) {
//                 var listItemText = listItemChildren[l]['text'];
//                 value = "$value ${k + 1}. $listItemText";
//
//                 if (l == listItemChildren.length - 1) {
//                   value += "\n"; // Add newline
//                 }
//               }
//             }
//           }
//         }
//         formStateProvider.setFieldValue(fieldData.name ?? "", value);
//       } else if (fieldData.value is String) {
//         console("TextFieldWidget VALUE STRING => ${fieldData.value}");
//         formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
//       }
//       console("Value => $value");
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // final HtmlEditorController controller = HtmlEditorController();
//     QuillController controller = QuillController.basic();
//
//     var value = "";
//     final formStateProvider =
//         Provider.of<ProcedureProvider>(context, listen: false);
//     if (fieldData.isRequired == true) {
//       formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
//     }
//
//     console("TextFieldWidget VALUE => ${fieldData.value}");
//     if (fieldData.value is List) {
//       console("TextFieldWidget VALUE List => ${fieldData.value}");
//       for (int i = 0; i < fieldData.value.length; i++) {
//         var type = fieldData.value[i]['type'];
//         if (type == "paragraph") {
//           List<dynamic> children = fieldData.value[i]['children'];
//
//           for (int j = 0; j < children.length; j++) {
//             var textValue = children[j]['text'];
//
//             value = "$value $textValue";
//
//             if (j == children.length - 1) {
//               value += "\n"; // Add newline
//             }
//           }
//         } else if (type == 'bulleted-list') {
//           List<dynamic> listItems = fieldData.value[i]['children'];
//
//           for (int k = 0; k < listItems.length; k++) {
//             var listItem = listItems[k];
//             var listItemType = listItem['type'];
//             var listItemChildren = listItem['children'];
//
//             for (int l = 0; l < listItemChildren.length; l++) {
//               var listItemText = listItemChildren[l]['text'];
//               value = "$value • $listItemText";
//
//               if (l == listItemChildren.length - 1) {
//                 value += "\n"; // Add newline
//               }
//             }
//           }
//         } else if (type == 'numbered-list') {
//           List<dynamic> listItems = fieldData.value[i]['children'];
//
//           for (int k = 0; k < listItems.length; k++) {
//             var listItem = listItems[k];
//             var listItemType = listItem['type'];
//             var listItemChildren = listItem['children'];
//
//             for (int l = 0; l < listItemChildren.length; l++) {
//               var listItemText = listItemChildren[l]['text'];
//               value = "$value ${k + 1}. $listItemText";
//
//               if (l == listItemChildren.length - 1) {
//                 value += "\n"; // Add newline
//               }
//             }
//           }
//         }
//       }
//       formStateProvider.setFieldValue(name ?? "", value);
//     } else if (fieldData.value is String) {
//       value = fieldData.value;
//       console("TextFieldWidget VALUE STRING => ${fieldData.value}");
//       formStateProvider.setFieldValue(name ?? "", value);
//     }
//     console("Value => $value");
//     // controller.
//     return Container(
//       padding: isBorderShowing
//           ? const EdgeInsets.fromLTRB(16, 8, 16, 8)
//           : EdgeInsets.zero,
//       margin: const EdgeInsets.only(top: 10),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(isBorderShowing ? 8 : 0),
//           color: Colors.white,
//           border: Border.all(
//               color: isBorderShowing ? chatBubbleSenderClosed : Colors.white,
//               width: isBorderShowing ? 1 : 0)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(
//             height: 8,
//           ),
//           TextView(
//               text: "$name ${isRequired ? "*" : ""}",
//               textColor: textColorLight,
//               textFontWeight: FontWeight.normal,
//               fontSize: 12),
//           const SizedBox(
//             height: 4,
//           ),
//           TextView(
//               text: description,
//               textColor: textColorDark,
//               textFontWeight: FontWeight.normal,
//               fontSize: 12),
//
//           const SizedBox(
//             height: 8,
//           ),
//           Container(
//             padding: const EdgeInsets.only(left: 10, right: 10),
//             height: 200,
//             width: context.fullWidth(),
//             decoration: BoxDecoration(
//               color: chatBubbleSenderClosed,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(8),
//                 topRight: Radius.circular(8),
//               ),
//             ),
//             child: QuillToolbar.simple(
//               configurations: QuillSimpleToolbarConfigurations(
//                 controller: controller,
//                 sharedConfigurations: const QuillSharedConfigurations(
//                   locale: Locale('en'),
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.only(left: 10, right: 10),
//             height: 200,
//             decoration: BoxDecoration(
//               color: chatBubbleSenderClosed,
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(8),
//                 bottomRight: Radius.circular(8),
//               ),
//             ),
//             child: QuillEditor.basic(
//               configurations: QuillEditorConfigurations(
//                 controller: controller,
//                 readOnly: false,
//                 sharedConfigurations: const QuillSharedConfigurations(
//                   locale: Locale('en'),
//                 ),
//               ),
//             ),
//           ),
//
//           AttachmentWidget(fieldData: fieldData),
//           const SizedBox(
//             height: 8,
//           ),
//
//           if (!isBorderShowing) const Divider(),
//           // TextField(
//           //   keyboardType: keyboardType,
//           // ),
//         ],
//       ),
//     );
//   }
// }

class NumberTextField extends StatelessWidget {
  final String name;
  final String description;
  final bool isRequired;
  final bool isBorderShowing;
  final TextInputType keyboardType;
  final BuildContext context;
  final ChildrenModel fieldData;
  final bool isEditable;
  final int index;
  final int parentIndex;
  final bool isAChildren;
  final bool isMultiline;

  NumberTextField(
      {super.key,
      required this.name,
      required this.description,
      required this.isBorderShowing,
      required this.isRequired,
      required this.context,
      required this.fieldData,
      required this.keyboardType,
      required this.index,
      required this.parentIndex,
      required this.isAChildren,
      required this.isMultiline,
      required this.isEditable}) {
    Future.delayed(const Duration(milliseconds: 0), () {
      final formStateProvider =
          Provider.of<ProcedureProvider>(context, listen: false);
      if (fieldData.isRequired == true) {
        formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
      }
      var value = "";
      console("TextFieldWidget VALUE => ${fieldData.value}");
      if (fieldData.value is List) {
        console("TextFieldWidget VALUE List => ${fieldData.value}");
        for (int i = 0; i < fieldData.value.length; i++) {
          var type = fieldData.value[i]['type'];
          if (type == "paragraph") {
            List<dynamic> children = fieldData.value[i]['children'];

            for (int j = 0; j < children.length; j++) {
              var textValue = children[j]['text'];

              value = "$value $textValue";

              if (j == children.length - 1) {
                value += "\n"; // Add newline
              }
            }
          } else if (type == 'bulleted-list') {
            List<dynamic> listItems = fieldData.value[i]['children'];

            for (int k = 0; k < listItems.length; k++) {
              var listItem = listItems[k];
              var listItemType = listItem['type'];
              var listItemChildren = listItem['children'];

              for (int l = 0; l < listItemChildren.length; l++) {
                var listItemText = listItemChildren[l]['text'];
                value = "$value • $listItemText";

                if (l == listItemChildren.length - 1) {
                  value += "\n"; // Add newline
                }
              }
            }
          } else if (type == 'numbered-list') {
            List<dynamic> listItems = fieldData.value[i]['children'];

            for (int k = 0; k < listItems.length; k++) {
              var listItem = listItems[k];
              var listItemType = listItem['type'];
              var listItemChildren = listItem['children'];

              for (int l = 0; l < listItemChildren.length; l++) {
                var listItemText = listItemChildren[l]['text'];
                value = "$value ${k + 1}. $listItemText";

                if (l == listItemChildren.length - 1) {
                  value += "\n"; // Add newline
                }
              }
            }
          }
        }
        formStateProvider.setFieldValue(fieldData.name ?? "", value);
      } else if (fieldData.value is String) {
        console("TextFieldWidget VALUE STRING => ${fieldData.value}");
        formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
      }
      console("Value => $value");
    });
  }

  @override
  Widget build(BuildContext context) {
    var value = "";
    final formStateProvider =
        Provider.of<ProcedureProvider>(context, listen: false);
    if (fieldData.isRequired == true) {
      formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
    }

    console("TextFieldWidget VALUE => ${fieldData.value}");
    if (fieldData.value is List) {
      console("TextFieldWidget VALUE List => ${fieldData.value}");
      for (int i = 0; i < fieldData.value.length; i++) {
        var type = fieldData.value[i]['type'];
        if (type == "paragraph") {
          List<dynamic> children = fieldData.value[i]['children'];

          for (int j = 0; j < children.length; j++) {
            var textValue = children[j]['text'];

            value = "$value $textValue";

            if (j == children.length - 1) {
              value += "\n"; // Add newline
            }
          }
        } else if (type == 'bulleted-list') {
          List<dynamic> listItems = fieldData.value[i]['children'];

          for (int k = 0; k < listItems.length; k++) {
            var listItem = listItems[k];
            var listItemType = listItem['type'];
            var listItemChildren = listItem['children'];

            for (int l = 0; l < listItemChildren.length; l++) {
              var listItemText = listItemChildren[l]['text'];
              value = "$value • $listItemText";

              if (l == listItemChildren.length - 1) {
                value += "\n"; // Add newline
              }
            }
          }
        } else if (type == 'numbered-list') {
          List<dynamic> listItems = fieldData.value[i]['children'];

          for (int k = 0; k < listItems.length; k++) {
            var listItem = listItems[k];
            var listItemType = listItem['type'];
            var listItemChildren = listItem['children'];

            for (int l = 0; l < listItemChildren.length; l++) {
              var listItemText = listItemChildren[l]['text'];
              value = "$value ${k + 1}. $listItemText";

              if (l == listItemChildren.length - 1) {
                value += "\n"; // Add newline
              }
            }
          }
        }
      }
      formStateProvider.setFieldValue(name ?? "", value);
    } else if (fieldData.value is String) {
      value = fieldData.value;
      console("TextFieldWidget VALUE STRING => ${fieldData.value}");
      formStateProvider.setFieldValue(name ?? "", value);
    }
    console("Value => $value");
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
              enabled: isEditable,
              minLines: isMultiline ? 10 : 1,
              maxLines: isMultiline ? 10 : 1,
              initialValue: value,
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
                var body;
                if (fieldData.type == "TEXT_AREA_FIELD") {
                  body = [
                    {
                      "type": "paragraph",
                      "children": [
                        {
                          "text": value,
                        },
                      ]
                    }
                  ];
                } else {
                  body = value;
                }
                if (isAChildren) {
                  Provider.of<ProcedureProvider>(context, listen: false)
                      .myProcedureRequest
                      ?.children?[parentIndex]
                      .children?[index]
                      .value = body;
                } else {
                  Provider.of<ProcedureProvider>(context, listen: false)
                      .myProcedureRequest
                      ?.children?[index]
                      .value = body;
                }
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
  final bool isEditable;
  final int index;
  final int parentIndex;
  final bool isAChildren;

  DatePickerWidget(
      {super.key,
      required this.name,
      required this.isRequired,
      required this.context,
      required this.fieldData,
      required this.index,
      required this.parentIndex,
      required this.isAChildren,
      required this.description,
      required this.isEditable}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      final formStateProvider =
          Provider.of<ProcedureProvider>(context, listen: false);
      if (fieldData.isRequired == true) {
        formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
      }

      var value;

      if (fieldData.value is List) {
        value = fieldData.value[0]['children'][0]['text'];
        formStateProvider.setFieldValue(fieldData.name ?? "", value);
      } else if (fieldData.value is String) {
        value = fieldData.value
            .toString()
            .convertStringDDMMYYYHHMMSSDateToEMMMDDYYYY();
        formStateProvider.setFieldValue(fieldData.name ?? "", value);
      } else {
        value = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate;
    final formStateProvider =
        Provider.of<ProcedureProvider>(context, listen: false);
    return ChangeNotifierProvider.value(
        value: Provider.of<ProcedureProvider>(context, listen: true),
        child: Column(
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
                if (isEditable) {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1870),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null && pickedDate != selectedDate) {
                    // setState(() {
                    //   _selectedDate = pickedDate;
                    // });
                    if (context.mounted) {
                      // Save the value to the state
                      final formStateProvider = Provider.of<ProcedureProvider>(
                          context,
                          listen: false);
                      formStateProvider.setFieldValue(
                          name, DateFormat('dd-MM-yyyy').format(pickedDate));

                      if (isAChildren) {
                        Provider.of<ProcedureProvider>(context, listen: false)
                                .myProcedureRequest
                                ?.children?[parentIndex]
                                .children?[index]
                                .value =
                            DateFormat("yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")
                                .format(pickedDate);
                      } else {
                        Provider.of<ProcedureProvider>(context, listen: false)
                                .myProcedureRequest
                                ?.children?[index]
                                .value =
                            DateFormat("yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")
                                .format(pickedDate);
                      }
                    }
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
                        text: Provider.of<ProcedureProvider>(context,
                                    listen: false)
                                .fieldValues[name] ??
                            fieldData.value ??
                            "mm/dd/yyy",
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
        ));
  }
}

class SectionWidget extends StatelessWidget {
  final ChildrenModel sectionData;
  final bool isEditable;
  final int parentIndex;
  final GetInventoryPartListResponse? inventoryPartListResponse;
  final GetListSupportAccountsResponse? listSupportAccountsResponse;
  final CurrentUser? userValue;
  final String procedureId;

  const SectionWidget(
      {super.key,
      required this.sectionData,
      required this.parentIndex,
      required this.isEditable,
      required this.userValue,
      required this.procedureId,
      required this.listSupportAccountsResponse,
      required this.inventoryPartListResponse});

  @override
  Widget build(BuildContext context) {
    final sectionChildren = sectionData.children ?? [];

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
          for (var entry in sectionChildren.asMap().entries)
            // for (var child in sectionChildren ?? [])
            FieldWidget(
              fieldData: entry.value,
              index: entry.key,
              isAChildren: true,
              parentIndex: parentIndex,
              isBorderShowing: false,
              procedureId: procedureId,
              isEditable: isEditable,
              userValue: userValue,
              listSupportAccountsResponse: listSupportAccountsResponse,
              inventoryPartListResponse: inventoryPartListResponse,
            ),
        ],
      ),
    );
  }
}

class ChecklistFieldWidget extends StatelessWidget {
  final ChildrenModel fieldData;
  final BuildContext context;
  final bool isEditable;
  final int index;
  final int parentIndex;
  final bool isAChildren;

  ChecklistFieldWidget(
      {super.key,
      required this.fieldData,
      required this.context,
      required this.index,
      required this.parentIndex,
      required this.isAChildren,
      required this.isEditable}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      final formStateProvider =
          Provider.of<ProcedureProvider>(context, listen: false);
      if (fieldData.isRequired == true) {
        formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
      }
      if (fieldData.value is List) {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        var value = fieldData.value as List<dynamic>;
        List<String> selectedOptions = List<String>.from(
            formStateProvider.fieldValues[fieldData.name] ?? []);
        for (var element in value) {
          selectedOptions.add(element);
        }
        formStateProvider.setFieldValue(fieldData.name ?? "", selectedOptions);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String name = fieldData.name ?? "";
    final String description = fieldData.description ?? "";
    final bool isRequired = fieldData.isRequired ?? false;
    final options = fieldData.options ?? [];

    console("ChecklistFieldWidget => ${fieldData.value}");

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
                    ?.contains(option.sId) ??
                false,
            // Set the actual value based on your logic
            onChanged: (value) {
              if (isEditable) {
                final formStateProvider =
                    Provider.of<ProcedureProvider>(context, listen: false);

                if (value != null) {
                  // Update the state with the selected options
                  List<String> selectedOptions = List<String>.from(
                      formStateProvider.fieldValues[name] ?? []);
                  if (value) {
                    selectedOptions.add(option.sId ?? "");
                  } else {
                    selectedOptions.remove(option.sId);
                  }

                  if (isAChildren) {
                    Provider.of<ProcedureProvider>(context, listen: false)
                        .myProcedureRequest
                        ?.children?[parentIndex]
                        .children?[index]
                        .value = selectedOptions;
                  } else {
                    Provider.of<ProcedureProvider>(context, listen: false)
                        .myProcedureRequest
                        ?.children?[index]
                        .value = selectedOptions;
                  }

                  formStateProvider.setFieldValue(name, selectedOptions);
                }
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
  final bool isEditable;
  final int index;
  final int parentIndex;
  final bool isAChildren;

  CheckboxFieldWidget(
      {super.key,
      required this.fieldData,
      required this.context,
      required this.index,
      required this.parentIndex,
      required this.isAChildren,
      required this.isEditable}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      final formStateProvider =
          Provider.of<ProcedureProvider>(context, listen: false);
      if (fieldData.isRequired == true) {
        formStateProvider.setFieldValue(fieldData.name ?? "", fieldData.value);
      }

      if (fieldData.value != null) {
        final formStateProvider =
            Provider.of<ProcedureProvider>(context, listen: false);
        var value = fieldData.value;

        if (value == true) {
          formStateProvider.setFieldValue(fieldData.name ?? "", true);
        } else {
          formStateProvider.setFieldValue(fieldData.name ?? "", false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String name = fieldData.name ?? "";
    final String description = fieldData.description ?? "";
    final bool isRequired = fieldData.isRequired ?? false;
    final options = fieldData.options ?? [];

    console("CheckboxFieldWidget => ${fieldData.value}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 16,
        ),
        TextView(
            text: description,
            textColor: Colors.black,
            textFontWeight: FontWeight.w500,
            fontSize: 14),
        CheckboxListTile(
          contentPadding: const EdgeInsets.all(0),
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          title: TextView(
              text: "$name ${isRequired ? "*" : ""}",
              textColor: Colors.black,
              textFontWeight: FontWeight.normal,
              fontSize: 14),
          value: Provider.of<ProcedureProvider>(context).fieldValues[name] ??
              false,
          onChanged: (value) {
            if (isEditable) {
              final formStateProvider =
                  Provider.of<ProcedureProvider>(context, listen: false);

              if (value != null) {
                if (isAChildren) {
                  Provider.of<ProcedureProvider>(context, listen: false)
                      .myProcedureRequest
                      ?.children?[parentIndex]
                      .children?[index]
                      .value = value;
                } else {
                  Provider.of<ProcedureProvider>(context, listen: false)
                      .myProcedureRequest
                      ?.children?[index]
                      .value = value;
                }

                Future.delayed(const Duration(milliseconds: 100), () {
                  if (value == true) {
                    formStateProvider.setFieldValue(name, value);
                    // formStateProvider.removeFieldValue(name);
                  } else {
                    formStateProvider.removeFieldValue(name);
                    // formStateProvider.setFieldValue(name, value);
                  }
                });
              }
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
        tilePadding: EdgeInsets.zero,
        trailing: const SizedBox(),
        shape: Border.all(width: 0),
        childrenPadding: EdgeInsets.zero,
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
                contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                leading: Icon(
                  Icons.document_scanner,
                  color: textColorLight,
                  size: 36,
                ),
                title: TextView(
                  text: item?.name ?? "",
                  textColor: textColorLight,
                  textFontWeight: FontWeight.bold,
                  fontSize: 12,
                  isEllipsis: true,
                ),
                subtitle: TextView(
                    text:
                        "${getFileType(item?.type ?? "")} • ${getFileSizeInKBs(item?.size ?? "")}",
                    textColor: textColorLight,
                    textFontWeight: FontWeight.normal,
                    fontSize: 12),
              );
            },
          )
        ],
      );
    }
    return const SizedBox();
  }
}
