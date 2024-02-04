// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/context_function.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/providers.dart';
import 'package:makula_oem/views/modals/bottom_sheet_generic_modal.dart';
import 'package:makula_oem/views/modals/bottom_sheet_image_chooser_dialog_hook.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/procedure_viewmodel.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/signature_hooks_procedure_screen.dart';
import 'package:path/path.dart';

import '../../../../../../helper/model/get_current_user_details_model.dart';
import '../../../../../../helper/model/get_inventory_part_list_response.dart';
import '../../../../../../helper/model/get_list_support_accounts_response.dart';
import '../../../../../../helper/model/get_procedure_by_id_response.dart';
import '../../../../../../helper/model/get_procedure_templates_response.dart';
import '../../../../../../helper/model/signature_model.dart';
import '../../../../../../helper/utils/colors.dart';
import '../../../../../../helper/utils/utils.dart';
import '../../../../../../main.dart';
import '../../../../../../pubnub/message_provider.dart';
import '../../../../../../pubnub/pubnub_instance.dart';
import '../../../../../widgets/custom_elevated_button.dart';
import '../../../../../widgets/dotter_border.dart';
import '../../../../../widgets/makula_text_view.dart';
import 'image_full_screen.dart';

class ProcedureScreenWithHooks extends HookConsumerWidget {
  final String? templatesId;
  final String? ticketName;
  PubnubInstance? pubnubInstance;
  MessageProvider? messageProvider;

  ProcedureScreenWithHooks(
      {super.key,
      required this.templatesId,
      required this.ticketName,
      required this.pubnubInstance,
      required this.messageProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));

    final procedureTemplateState =
        ref.watch(procedureTemplateProvider.notifier);
    final procedureFormState = ref.watch(procedureFormStateProvider.notifier);
    final procedureFormFinalizedState =
        ref.watch(procedureFormFinalizedProvider.notifier);
    final procedureSignatureState =
        ref.watch(procedureSignatureStateProvider.notifier);
    final procedureSignatureCheckAnyTrueState =
        ref.watch(procedureSignatureCheckAnyTrueStateProvider.notifier);

    ListOwnOemProcedureTemplates? templates;
    GetInventoryPartListResponse? inventoryPartListResponse;
    GetListSupportAccountsResponse? listSupportAccountsResponse;
    CurrentUser? userValue;
    List<ChildrenModel> procedures = [];

    observerGetListSupportAccounts(
        GetListSupportAccountsResponse response) async {
      listSupportAccountsResponse = response;
      await appDatabase?.getListSupportAccountsResponseDao
          .insertResponse(response);
    }

    getListSupportAccounts() async {
      var isConnected = await isConnectedToNetwork();
      if (isConnected) {
        var result = await ProcedureViewModel().getListSupportAccounts();
        result.join(
            (failed) => {console("failed => ${failed.exception}")},
            (loaded) => {
                  observerGetListSupportAccounts(loaded.data),
                },
            (loading) => {
                  console("loading => "),
                });
      } else {
        listSupportAccountsResponse = await appDatabase
            ?.getListSupportAccountsResponseDao
            .getSupportAccount();
        await appDatabase?.getListSupportAccountsResponseDao
            .getSupportAccount();
      }
    }

    observerGetInventoryParts(GetInventoryPartListResponse response) async {
      inventoryPartListResponse = response;
      await appDatabase?.partModelDao
          .insertInventoryPartModel(response.listOwnOemInventoryPart!);
    }

    getInventoryParts() async {
      var isConnected = await isConnectedToNetwork();
      if (isConnected) {
        var result = await ProcedureViewModel().getInventoryPartList();
        result.join(
            (failed) => {console("failed => ${failed.exception}")},
            (loaded) => {
                  observerGetInventoryParts(loaded.data),
                },
            (loading) => {
                  console("loading => "),
                });
      } else {
        inventoryPartListResponse = GetInventoryPartListResponse();
        inventoryPartListResponse?.listOwnOemInventoryPart =
            await appDatabase?.partModelDao.getInventoryPartModel();
        await appDatabase?.partModelDao.getInventoryPartModel();
      }
    }

    observerGetProcedureByIdResponse(GetProcedureByIdResponse response) async {
      templates = response.getOwnOemProcedureById;
      procedures = templates?.children ?? [];
      // procedureTemplateState.state = templates;
      var savedTemplates = await appDatabase?.getProcedureByIdResponseDao
          .getProcedureById(templatesId ?? "");


      var isOffline = await AppPreferences().getBool(AppPreferences.IS_OFFLINE) ?? false;
      console("observerGetProcedureByIdResponse isOffline => $isOffline");

      if (savedTemplates == null) {
        templates = response.getOwnOemProcedureById;
        procedures = templates?.children ?? [];
        await appDatabase?.getProcedureByIdResponseDao
            .insertListOwnOemProcedureTemplatesById(
                response.getOwnOemProcedureById!);

        ref.watch(procedureFormStateProvider.notifier).resetChanges();
        ref.watch(procedureTemplateProvider.notifier).updateValue(templates);
        ref.watch(procedureFormFinalizedProvider.notifier).reset();
        ref
            .watch(procedureFormFinalizedProvider.notifier)
            .checkIfAllRequiredFieldsAreFilled(
                ref.watch(procedureTemplateProvider.notifier).state);
        ref.watch(procedureSignatureStateProvider.notifier).update(templates);
        ref
            .watch(procedureSignatureCheckAnyTrueStateProvider.notifier)
            .update(templates);
      }
      else {
        if (isOffline) {
          var childrenModel = savedTemplates.children;
          var signatureModel = savedTemplates.signatures;
          List<SignatureRequestModel> signatureList = [];
          await AppPreferences().setBool(AppPreferences.IS_OFFLINE, false);
          templates = savedTemplates;
          templates?.state = response.getOwnOemProcedureById?.state;

          procedures = templates?.children ?? [];

          ref.watch(procedureFormStateProvider.notifier).resetChanges();
          ref
              .watch(procedureTemplateProvider.notifier)
              .updateValue(savedTemplates);
          ref.watch(procedureFormFinalizedProvider.notifier).reset();
          ref
              .watch(procedureFormFinalizedProvider.notifier)
              .checkIfAllRequiredFieldsAreFilled(
              ref.watch(procedureTemplateProvider.notifier).state);
          ref
              .watch(procedureSignatureStateProvider.notifier)
              .update(savedTemplates);
          ref
              .watch(procedureSignatureCheckAnyTrueStateProvider.notifier)
              .update(savedTemplates);

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
              templatesId ?? "", childrenModel, signatureList);
          result.join(
                  (failed) => {console("failed => ${failed.exception}")},
                  (loaded) => {
                console("loaded => ${loaded.data}"),
              },
                  (loading) => {
                console("loading => "),
              });

        }
        else {
          templates = response.getOwnOemProcedureById;
          procedures = templates?.children ?? [];
          await appDatabase?.getProcedureByIdResponseDao
              .insertListOwnOemProcedureTemplatesById(
              response.getOwnOemProcedureById!);

          ref.watch(procedureFormStateProvider.notifier).resetChanges();
          ref.watch(procedureTemplateProvider.notifier).updateValue(templates);
          ref.watch(procedureFormFinalizedProvider.notifier).reset();
          ref
              .watch(procedureFormFinalizedProvider.notifier)
              .checkIfAllRequiredFieldsAreFilled(
              ref.watch(procedureTemplateProvider.notifier).state);
          ref.watch(procedureSignatureStateProvider.notifier).update(templates);
          ref
              .watch(procedureSignatureCheckAnyTrueStateProvider.notifier)
              .update(templates);
        }
      }
    }

    getValueFromSP() async {
      userValue = (await appDatabase?.userDao.getCurrentUserDetailsFromDb())!;

      if (context.mounted) {
        pubnubInstance = PubnubInstance(context);
        pubnubInstance
            ?.setSubscriptionChannel(userValue?.notificationChannel ?? "");
        messageProvider = MessageProvider(
            pubnubInstance!, userValue?.notificationChannel ?? "");
      }

      messageProvider?.addListener(() {
        if (context.mounted) {
          if (messageProvider?.downloadProcedurePDFLoading == false) {
            Navigator.pop(context);
            var payload = messageProvider?.downloadProcedureData["payload"];
            var url = payload["url"];
            newLaunchURL(url.toString().replaceAll(" ", "%20"));
            console(
                "messageProvider?.downloadProcedurePDFLoading => ${messageProvider?.downloadProcedureData}");
          }
          if (messageProvider?.showFinalizeProcedureLoading == false) {
            Navigator.pop(context);
            Future.delayed(const Duration(milliseconds: 500), () {
              ref.refresh(procedureTemplateProvider);
            });
          }
        }
      });
    }

    getProcedureById(String procedureId) async {
      await getValueFromSP();
      await getInventoryParts();
      await getListSupportAccounts();
      var isConnected = await isConnectedToNetwork();
      console("_getProcedureById -> templatesId => $templatesId");
      if (isConnected) {
        var result = await ProcedureViewModel().getProcedureById(procedureId);
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
        await AppPreferences().setBool(AppPreferences.IS_OFFLINE, true);
        templates = await appDatabase?.getProcedureByIdResponseDao
            .getProcedureById(procedureId);
        procedures = templates?.children ?? [];

        console("_getProcedureById -> Response => ${templates?.sId}");

        ref.watch(procedureFormStateProvider.notifier).resetChanges();
        ref.watch(procedureTemplateProvider.notifier).updateValue(templates);
        ref.watch(procedureFormFinalizedProvider.notifier).reset();
        ref
            .watch(procedureFormFinalizedProvider.notifier)
            .checkIfAllRequiredFieldsAreFilled(
                ref.watch(procedureTemplateProvider.notifier).state);
        ref.watch(procedureSignatureStateProvider.notifier).update(templates);
        ref
            .watch(procedureSignatureCheckAnyTrueStateProvider.notifier)
            .update(templates);
        await appDatabase?.getProcedureByIdResponseDao
            .getProcedureById(procedureId);
      }
    }

    void refreshScreen(bool isRefresh) {
      Future.delayed(const Duration(seconds: 1), () async {
        var procedureTemplateState =
            ref.watch(procedureTemplateProvider.notifier).state;
        var templates = await appDatabase?.getProcedureByIdResponseDao
            .getProcedureById(templatesId ?? "");
        // var isConnected = await isConnectedToNetwork();
        // if (!isConnected) {
        //   console("isConnectedisConnectedisConnected > $isConnected");
        //   console("isConnectedisConnectedisConnected > ${templates?.state}");
        //   procedureTemplateState?.state = "DRAFT";
        //   console("isConnectedisConnectedisConnected > ${templates?.state}");
        // }
        var childrenModel = procedureTemplateState?.children;
        var signatureModel = procedureTemplateState?.signatures;
        templates?.children = childrenModel;
        templates?.signatures = signatureModel;


        await appDatabase?.getProcedureByIdResponseDao.updateListOwnOemProcedureTemplates(procedureTemplateState!);

        ref.watch(procedureFormStateProvider.notifier).resetChanges();
        if (isRefresh) {
          ref.refresh(procedureTemplateProvider);
        }
      });
    }

    return FutureBuilder(
        future: getProcedureById(templatesId ?? ""),
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }
          console("ProcedureScreen: TEMPLATE => ${templates?.sId}");
          console("ProcedureScreen: CURRENT USER => ${userValue?.name}");
          console(
              "ProcedureScreen: getInventoryParts => ${inventoryPartListResponse?.listOwnOemInventoryPart?.parts?.length}");
          console(
              "ProcedureScreen: getListSupportAccounts => ${listSupportAccountsResponse?.listOwnOemSupportAccounts?.length}");
          return WillPopScope(
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  centerTitle: false,
                  leading: GestureDetector(
                      onTap: () {
                        var formState = ref
                            .watch(procedureFormStateProvider.notifier)
                            .state;
                        if (formState && templates?.state != "FINALIZED") {
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
                                          ref.invalidate(
                                              procedureTemplateProvider);
                                          ref.invalidate(
                                              selectedImageListProvider);
                                          ref.invalidate(
                                              procedureFormStateProvider);
                                          ref.invalidate(
                                              procedureFormFinalizedProvider);
                                          ref.invalidate(
                                              procedureSignatureStateProvider);
                                          Navigator.pop(context, "refresh");
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
                          ref.invalidate(procedureTemplateProvider);
                          ref.invalidate(selectedImageListProvider);
                          ref.invalidate(procedureFormStateProvider);
                          ref.invalidate(procedureFormFinalizedProvider);
                          ref.invalidate(procedureSignatureStateProvider);
                          Navigator.pop(context, "refresh");
                        }
                      },
                      child: const Icon(Icons.arrow_back_ios)),
                  backgroundColor: Colors.grey.shade200,
                  title: TextView(
                      text: "$ticketName / ${templates?.name}",
                      textColor: textColorDark,
                      textFontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                body: Container(
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
                                    onTap: () async {
                                      if (templates?.state == "FINALIZED") {
                                        launchURL(templates?.pdfUrl
                                                ?.replaceAll(" ", "%20") ??
                                            "");
                                      } else {
                                        context.showCustomDialog();
                                        var result = await ProcedureViewModel()
                                            .downloadProcedurePDF(
                                                templatesId ?? "",
                                                generateRandomString());
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
                                        color: templates?.state != "FINALIZED"
                                            ? lightGray
                                            : closedContainerColor,
                                        borderRadius: BorderRadius.circular(8)),
                                    alignment: Alignment.center,
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 4, 4, 5),
                                    child: TextView(
                                        align: TextAlign.center,
                                        text: templates?.state
                                                ?.replaceAll("_", " ") ??
                                            "",
                                        textColor:
                                            templates?.state != "FINALIZED"
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
                              StreamBuilder<bool>(
                                  stream: procedureSignatureCheckAnyTrueState
                                      .stream,
                                  builder: (context, snapshot) {
                                    return StreamBuilder<bool>(
                                        stream:
                                            procedureFormFinalizedState.stream,
                                        builder: (context, snapshot) {
                                          console(
                                              "procedureSignatureCheckAnyTrueStateProvider => ${templates?.state != "FINALIZED"} --- ${ref.watch(procedureSignatureCheckAnyTrueStateProvider.notifier).state}");
                                          return FieldWidget(
                                            fieldData: entry.value,
                                            isBorderShowing: true,
                                            index: entry.key,
                                            parentIndex: -1,
                                            isAChildren: false,
                                            userValue: userValue,
                                            procedureId: templatesId ?? "",
                                            listSupportAccountsResponse:
                                                listSupportAccountsResponse,
                                            isEditable: (templates?.state !=
                                                    "FINALIZED" &&
                                                ref
                                                    .watch(
                                                        procedureSignatureCheckAnyTrueStateProvider
                                                            .notifier)
                                                    .state),
                                            inventoryPartListResponse:
                                                inventoryPartListResponse,
                                          );
                                        });
                                  }),
                            const SizedBox(height: 16),
                            if (templates?.signatures?.isNotEmpty == true)
                              StreamBuilder<bool>(
                                  stream: procedureFormFinalizedState.stream,
                                  builder: (context, snapshot) {
                                    console(
                                        "StreamBuilder SignatureWidget => ${ref.watch(procedureFormFinalizedProvider.notifier).state}");
                                    return SignatureWidget(
                                      signatureModel: templates?.signatures,
                                      isEditable: (templates?.state !=
                                              "FINALIZED" &&
                                          ref
                                              .watch(
                                                  procedureFormFinalizedProvider
                                                      .notifier)
                                              .state),
                                      currentUser: userValue,
                                      context: context,
                                      procedureId: templatesId ?? "",
                                    );
                                  }),
                          ],
                        ),
                      )),
                      if (templates?.state != "FINALIZED")
                        ActionButtons(
                          templatesId: templatesId ?? "",
                          templates: templates,
                          refreshCallback: (isRefreshed) {
                            refreshScreen(isRefreshed);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              onWillPop: () async {
                var formState =
                    ref.watch(procedureFormStateProvider.notifier).state;
                if (formState && templates?.state != "FINALIZED") {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Are you sure you want to leave?'),
                          content: const Text(
                              'By continuing without saving, you will lose all your work and updates. Are you sure you want to leave?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
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
                                  ref.invalidate(procedureTemplateProvider);
                                  ref.invalidate(selectedImageListProvider);
                                  ref.invalidate(procedureFormStateProvider);
                                  ref.invalidate(
                                      procedureFormFinalizedProvider);
                                  ref.invalidate(
                                      procedureSignatureStateProvider);
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
                } else {
                  ref.invalidate(procedureTemplateProvider);
                  ref.invalidate(selectedImageListProvider);
                  ref.invalidate(procedureFormStateProvider);
                  ref.invalidate(procedureFormFinalizedProvider);
                  ref.invalidate(procedureSignatureStateProvider);
                  return true;
                }
              });
        });
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
    switch (type) {
      case 'HEADING':

        ///DONE
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
        return TextAreaFieldWidget(
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

        ///DONE
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

        ///DONE
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

        ///DONE
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

        ///DONE
        return ChecklistFieldWidget(
          fieldData: fieldData,
          context: context,
          index: index,
          parentIndex: parentIndex,
          isAChildren: isAChildren,
          isEditable: isEditable,
        );

      case 'CHECKBOX_FIELD':

        ///DONE
        return CheckboxFieldWidget(
          fieldData: fieldData,
          context: context,
          index: index,
          parentIndex: parentIndex,
          isAChildren: isAChildren,
          isEditable: isEditable,
        );

      case 'IMAGE_UPLOADER_FIELD':

        ///DONE
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

        ///DONE
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

        ///DONE
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

      case 'MEMBER_FIELD':

        ///DONE
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

      case 'TABLE_FIELD':

        ///DONE
        return TableFieldWidget(
          fieldData: fieldData,
          context: context,
          isEditable: isEditable,
          index: index,
          parentIndex: parentIndex,
          isAChildren: isAChildren,
        );

      // Add more cases for other field types as needed
      default:
        return Container(); // Placeholder for unknown field types
    }
  }
}

class SectionWidget extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionChildren = sectionData.children ?? [];
    final procedureTemplateState =
        ref.watch(procedureTemplateProvider.notifier);

    return StreamBuilder<ListOwnOemProcedureTemplates?>(
        stream: procedureTemplateState.stream,
        builder: (context, snapshot) {
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
        });
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
    console("");
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
        // AttachmentWidget(fieldData: fieldData),
      ],
    );
  }
}

class TextAreaFieldWidget extends HookConsumerWidget {
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

  TextAreaFieldWidget(
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
    console("");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    console("TextAreaFieldWidget => value: ${fieldData.value}");
    final procedureTemplateState =
        ref.watch(procedureTemplateProvider.notifier);
    // QuillController controller = QuillController.basic();
    // controller.addListener(() {
    //   console("QUILL -> ${controller.document.toPlainText()}");
    //         // ref
    //         //     .watch(procedureTemplateProvider.notifier)
    //         //     .state
    //         //     ?.children?[parentIndex]
    //         //     .children?[index]
    //         //     .value = controller.document.toDelta().toJson();
    //         // ref
    //         //     .watch(procedureFormStateProvider.notifier)
    //         //     .markChanges("", controller.document.toDelta().toJson());
    //         // ref
    //         //     .watch(procedureFormFinalizedProvider.notifier)
    //         //     .checkIfAllRequiredFieldsAreFilled(
    //         //     ref
    //         //         .watch(procedureTemplateProvider.notifier)
    //         //         .state);
    // });
    var oldValue = "";
    if (fieldData.value == null) {
      oldValue = "";
    } else {
      if (fieldData.value is List) {
        for (int i = 0; i < fieldData.value.length; i++) {
          var type = fieldData.value[i]['type'];
          if (type == "paragraph") {
            List<dynamic> children = fieldData.value[i]['children'];

            for (int j = 0; j < children.length; j++) {
              var textValue = children[j]['text'];

              oldValue = "$oldValue $textValue";

              if (j == children.length - 1) {
                oldValue += "\n"; // Add newline
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
                oldValue = "$oldValue • $listItemText";

                if (l == listItemChildren.length - 1) {
                  oldValue += "\n"; // Add newline
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
                oldValue = "$oldValue ${k + 1}. $listItemText";

                if (l == listItemChildren.length - 1) {
                  oldValue += "\n"; // Add newline
                }
              }
            }
          }
        }
        // oldValue = fieldData.value.toString() ?? "";
      }
    }
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
              initialValue: oldValue,
              minLines: isMultiline ? 10 : 1,
              maxLines: isMultiline ? 10 : 1,
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
                var body;
                if (value.isNotEmpty) {
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
                  body = null;
                }
                if (isAChildren) {
                  ref
                      .watch(procedureTemplateProvider.notifier)
                      .state
                      ?.children?[parentIndex]
                      .children?[index]
                      .value = body;
                } else {
                  ref
                      .watch(procedureTemplateProvider.notifier)
                      .state
                      ?.children?[index]
                      .value = body;
                }
                ref
                    .watch(procedureFormStateProvider.notifier)
                    .markChanges(oldValue, value);
                ref
                    .watch(procedureFormFinalizedProvider.notifier)
                    .checkIfAllRequiredFieldsAreFilled(
                        ref.watch(procedureTemplateProvider.notifier).state);
              },
            ),
          ),

          //   Container(
          //   padding: const EdgeInsets.only(left: 10, right: 10),
          //   height: 200,
          //   width: context.fullWidth(),
          //   decoration: BoxDecoration(
          //     color: chatBubbleSenderClosed,
          //     borderRadius: const BorderRadius.only(
          //       topLeft: Radius.circular(8),
          //       topRight: Radius.circular(8),
          //     ),
          //   ),
          //   child: QuillToolbar.simple(
          //     configurations: QuillSimpleToolbarConfigurations(
          //       controller: controller,
          //       sharedConfigurations: const QuillSharedConfigurations(
          //         locale: Locale('en'),
          //       ),
          //     ),
          //   ),
          // ),
          // Container(
          //   padding: const EdgeInsets.only(left: 10, right: 10),
          //   height: 200,
          //   decoration: BoxDecoration(
          //     color: chatBubbleSenderClosed,
          //     borderRadius: const BorderRadius.only(
          //       bottomLeft: Radius.circular(8),
          //       bottomRight: Radius.circular(8),
          //     ),
          //   ),
          //   child: QuillEditor.basic(
          //
          //     configurations: QuillEditorConfigurations(
          //
          //       controller: controller,
          //       readOnly: false,
          //       sharedConfigurations: const QuillSharedConfigurations(
          //         locale: Locale('en'),
          //       ),
          //     ),
          //   ),
          // ),
          AttachmentWidget(fieldData: fieldData),

          if (!isBorderShowing) const Divider(),
          // TextField(
          //   keyboardType: keyboardType,
          // ),
        ],
      ),
    );
  }
}

class NumberTextField extends HookConsumerWidget {
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
    console("NumberTextField=>${fieldData.value}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final procedureTemplateState =
        ref.watch(procedureTemplateProvider.notifier);
    final procedureFormState = ref.watch(procedureFormStateProvider.notifier);
    var oldValue = fieldData.value ?? "";
    return StreamBuilder<ListOwnOemProcedureTemplates?>(
        stream: procedureTemplateState.stream,
        builder: (context, snapshot) {
          return Container(
            padding: isBorderShowing
                ? const EdgeInsets.fromLTRB(16, 8, 16, 8)
                : EdgeInsets.zero,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isBorderShowing ? 8 : 0),
                color: Colors.white,
                border: Border.all(
                    color:
                        isBorderShowing ? chatBubbleSenderClosed : Colors.white,
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
                    initialValue: oldValue,
                    minLines: isMultiline ? 10 : 1,
                    maxLines: isMultiline ? 10 : 1,
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
                      if (isAChildren) {
                        ref
                            .watch(procedureTemplateProvider.notifier)
                            .state
                            ?.children?[parentIndex]
                            .children?[index]
                            .value = value;
                      } else {
                        ref
                            .watch(procedureTemplateProvider.notifier)
                            .state
                            ?.children?[index]
                            .value = value;
                      }
                      ref
                          .watch(procedureFormStateProvider.notifier)
                          .markChanges(oldValue, value);

                      ref
                          .watch(procedureFormFinalizedProvider.notifier)
                          .checkIfAllRequiredFieldsAreFilled(ref
                              .watch(procedureTemplateProvider.notifier)
                              .state);
                    },
                  ),
                ),

                AttachmentWidget(fieldData: fieldData),

                if (!isBorderShowing) const Divider(),
                // TextField(
                //   keyboardType: keyboardType,
                // ),
              ],
            ),
          );
        });
  }
}

class SignatureWidget extends HookConsumerWidget {
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
    console("");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var procedureTemplateState = ref.watch(procedureTemplateProvider.notifier);
    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder<ListOwnOemProcedureTemplates?>(
          stream: procedureTemplateState.stream,
          builder: (context, snapshot) {
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
                      itemCount: ref
                              .watch(procedureTemplateProvider.notifier)
                              .state
                              ?.signatures
                              ?.length ??
                          0,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var item = ref
                            .watch(procedureTemplateProvider.notifier)
                            .state
                            ?.signatures?[index];
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
                                FocusScope.of(context).unfocus();
                                if (isEditable) {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: convertStringToDateTime(ref
                                        .watch(
                                            procedureTemplateProvider.notifier)
                                        .state
                                        ?.signatures?[index]
                                        .date),
                                    firstDate: DateTime(1870),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    ref
                                        .watch(
                                            procedureTemplateProvider.notifier)
                                        .state
                                        ?.signatures?[index]
                                        .date = DateFormat(
                                            "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")
                                        .format(pickedDate);
                                    ref
                                        .watch(
                                            procedureFormStateProvider.notifier)
                                        .markChanges("", pickedDate.toString());
                                    ref
                                        .watch(procedureFormFinalizedProvider
                                            .notifier)
                                        .checkIfAllRequiredFieldsAreFilled(ref
                                            .watch(procedureTemplateProvider
                                                .notifier)
                                            .state);

                                    ref
                                        .watch(procedureSignatureStateProvider
                                            .notifier)
                                        .update(ref
                                            .watch(procedureTemplateProvider
                                                .notifier)
                                            .state);
                                    setState(() {});
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextView(
                                          text: convertStringDateToDDMMYYYY(
                                              item?.date),
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
                                text: (ref
                                                .watch(procedureTemplateProvider
                                                    .notifier)
                                                .state
                                                ?.signatures
                                                ?.length ??
                                            0) >
                                        1
                                    ? "Signature${index + 1} name"
                                    : "Signature name",
                                textColor: textColorDark,
                                textFontWeight: FontWeight.normal,
                                fontSize: 12),
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextFormField(
                                style: TextStyle(
                                    color: textColorDark, fontSize: 12),
                                enabled: isEditable,
                                // Use the field name as the key
                                initialValue: item?.name ?? "",
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter Name",
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  return null;
                                },
                                onChanged: (value) {
                                  var listOwnOemProcedureTemplates = ref
                                      .watch(procedureTemplateProvider.notifier)
                                      .state;

                                  var signature = listOwnOemProcedureTemplates
                                      ?.signatures?[index];
                                  signature?.name = value;

                                  ref
                                      .watch(procedureTemplateProvider.notifier)
                                      .updateValue(
                                          listOwnOemProcedureTemplates);
                                  ref
                                      .watch(
                                          procedureFormStateProvider.notifier)
                                      .markChanges("", value);
                                  ref
                                      .watch(procedureFormFinalizedProvider
                                          .notifier)
                                      .checkIfAllRequiredFieldsAreFilled(ref
                                          .watch(procedureTemplateProvider
                                              .notifier)
                                          .state);
                                  ref
                                      .watch(procedureSignatureStateProvider
                                          .notifier)
                                      .update(ref
                                          .watch(procedureTemplateProvider
                                              .notifier)
                                          .state);
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
                                FocusScope.of(context).unfocus();
                                if (isEditable) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SignatureHooksProcedureScreen(
                                              index: index,
                                              currentUser: currentUser,
                                              procedureId: procedureId,
                                              onSelect: () {
                                                ref
                                                    .watch(
                                                        procedureSignatureStateProvider
                                                            .notifier)
                                                    .update(ref
                                                        .watch(
                                                            procedureTemplateProvider
                                                                .notifier)
                                                        .state);

                                                ref
                                                    .watch(
                                                        procedureSignatureCheckAnyTrueStateProvider
                                                            .notifier)
                                                    .update(ref
                                                        .watch(
                                                            procedureTemplateProvider
                                                                .notifier)
                                                        .state);
                                                ref
                                                    .watch(
                                                        procedureFormStateProvider
                                                            .notifier)
                                                    .markChanges("", "1");
                                                setState(() {});
                                              },
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
                                child: item?.signatureUrl == null
                                    ? TextView(
                                        text: "Sign here",
                                        textColor: textColorLight,
                                        textFontWeight: FontWeight.normal,
                                        fontSize: 12)
                                    : Stack(
                                        children: [
                                          SizedBox(
                                            width: context.fullWidth(),
                                            child: CachedNetworkImage(
                                              errorWidget:
                                                  (context, url, error) =>
                                                      CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    const Padding(
                                                  padding: EdgeInsets.zero,
                                                  child:
                                                      CircularProgressIndicator
                                                          .adaptive(),
                                                ),
                                                imageUrl:
                                                    item?.signatureUrl ?? "",
                                              ),
                                              placeholder: (context, url) =>
                                                  const Padding(
                                                padding: EdgeInsets.zero,
                                                child: CircularProgressIndicator
                                                    .adaptive(),
                                              ),
                                              imageUrl:
                                                  item?.signatureUrl ?? "",
                                            ),
                                          ),
                                          if (ref
                                                  .watch(
                                                      procedureTemplateProvider
                                                          .notifier)
                                                  .state
                                                  ?.state !=
                                              "FINALIZED")
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                  onTap: () {
                                                    var listOwnOemProcedureTemplates = ref
                                                        .watch(
                                                            procedureTemplateProvider
                                                                .notifier)
                                                        .state;

                                                    var signature =
                                                        listOwnOemProcedureTemplates
                                                                ?.signatures?[
                                                            index];
                                                    signature?.signatureUrl =
                                                        null;
                                                    ref
                                                        .watch(
                                                            procedureSignatureStateProvider
                                                                .notifier)
                                                        .update(
                                                            listOwnOemProcedureTemplates);
                                                    ref
                                                        .watch(
                                                            procedureSignatureCheckAnyTrueStateProvider
                                                                .notifier)
                                                        .update(
                                                            listOwnOemProcedureTemplates);

                                                    ref
                                                        .watch(
                                                            procedureFormStateProvider
                                                                .notifier)
                                                        .markChanges("", "1");
                                                    setState(() {});
                                                  },
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.grey,
                                                  )),
                                            )
                                        ],
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
                ));
          });
    });
  }
}

class DatePickerWidget extends HookConsumerWidget {
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
    console("");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final procedureTemplateState =
        ref.watch(procedureTemplateProvider.notifier);
    DateTime? selectedDate;
    String? oldValue;
    if (fieldData.value != null) {
      oldValue = fieldData.value;
      selectedDate = convertStringToDateTime(fieldData.value);
    }
    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder<ListOwnOemProcedureTemplates?>(
          stream: procedureTemplateState.stream,
          builder: (context, snapshot) {
            return Column(
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
                    FocusScope.of(context).unfocus();
                    if (isEditable) {
                      console("DatePickerWidget - selectedDate: $selectedDate");
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: isAChildren
                            ? convertStringToDateTime(ref
                                .watch(procedureTemplateProvider.notifier)
                                .state
                                ?.children?[parentIndex]
                                .children?[index]
                                .value)
                            : convertStringToDateTime(ref
                                .watch(procedureTemplateProvider.notifier)
                                .state
                                ?.children?[index]
                                .value),
                        firstDate: DateTime(1870),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null) {
                        if (isAChildren) {
                          ref
                                  .watch(procedureTemplateProvider.notifier)
                                  .state
                                  ?.children?[parentIndex]
                                  .children?[index]
                                  .value =
                              DateFormat("yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")
                                  .format(pickedDate);

                          console(
                              "DatePickerWidget - selectedDate: ${ref.watch(procedureTemplateProvider.notifier).state?.children?[parentIndex].children?[index].value}");
                        } else {
                          ref
                                  .watch(procedureTemplateProvider.notifier)
                                  .state
                                  ?.children?[index]
                                  .value =
                              DateFormat("yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")
                                  .format(pickedDate);
                        }
                        ref
                            .watch(procedureFormStateProvider.notifier)
                            .markChanges(
                                oldValue.toString(), pickedDate.toString());
                        ref
                            .watch(procedureFormFinalizedProvider.notifier)
                            .checkIfAllRequiredFieldsAreFilled(ref
                                .watch(procedureTemplateProvider.notifier)
                                .state);
                        setState(() {});
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
                            text: isAChildren
                                ? (convertStringDateToDDMMYYYY(ref
                                    .watch(procedureTemplateProvider.notifier)
                                    .state
                                    ?.children?[parentIndex]
                                    .children?[index]
                                    .value))
                                : convertStringDateToDDMMYYYY(ref
                                    .watch(procedureTemplateProvider.notifier)
                                    .state
                                    ?.children?[index]
                                    .value),
                            textColor: Colors.grey.shade800,
                            textFontWeight: FontWeight.normal,
                            fontSize: 12),
                        const Icon(Icons.calendar_month)
                      ],
                    ),
                  ),
                ),
                AttachmentWidget(fieldData: fieldData),
                const Divider(),
              ],
            );
          });
    });
  }
}

class CheckboxFieldWidget extends HookConsumerWidget {
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
    console("");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String name = fieldData.name ?? "";
    final String description = fieldData.description ?? "";
    final bool isRequired = fieldData.isRequired ?? false;
    final options = fieldData.options ?? [];
    final procedureTemplateState =
        ref.watch(procedureTemplateProvider.notifier);
    final procedureFormStateState =
        ref.watch(procedureFormStateProvider.notifier);
    var oldValue = fieldData.value ?? false;

    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder<bool>(
          stream: procedureFormStateState.stream,
          builder: (context, snapshot) {
            console("StreamBuilder");
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (description.isNotEmpty)
                  const SizedBox(
                    height: 16,
                  ),
                if (description.isNotEmpty)
                  TextView(
                      text: description,
                      textColor: Colors.black,
                      textFontWeight: FontWeight.w500,
                      fontSize: 14),
                CheckboxListTile(
                  contentPadding: const EdgeInsets.all(0),
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -4),
                  title: TextView(
                      text: "$name ${isRequired ? "*" : ""}",
                      textColor: Colors.black,
                      textFontWeight: FontWeight.normal,
                      fontSize: 14),
                  value: isAChildren
                      ? (ref
                              .watch(procedureTemplateProvider.notifier)
                              .state
                              ?.children?[parentIndex]
                              .children?[index]
                              .value ??
                          false)
                      : ref
                              .watch(procedureTemplateProvider.notifier)
                              .state
                              ?.children?[index]
                              .value ??
                          false,
                  onChanged: (value) {
                    FocusScope.of(context).unfocus();
                    if (isEditable) {
                      if (isAChildren) {
                        var listOwnOemProcedureTemplates =
                            ref.watch(procedureTemplateProvider.notifier).state;
                        listOwnOemProcedureTemplates?.children?[parentIndex]
                            .children?[index].value = value;
                        ref
                            .watch(procedureTemplateProvider.notifier)
                            .updateValue(listOwnOemProcedureTemplates);
                      } else {
                        var listOwnOemProcedureTemplates =
                            ref.watch(procedureTemplateProvider.notifier).state;
                        listOwnOemProcedureTemplates?.children?[index].value =
                            value;
                        ref
                            .watch(procedureTemplateProvider.notifier)
                            .updateValue(listOwnOemProcedureTemplates);
                      }
                      ref
                          .watch(procedureFormStateProvider.notifier)
                          .markChanges(oldValue.toString(), value.toString());
                      ref
                          .watch(procedureFormFinalizedProvider.notifier)
                          .checkIfAllRequiredFieldsAreFilled(ref
                              .watch(procedureTemplateProvider.notifier)
                              .state);
                      setState(() {});
                    }
                  },
                ),
                AttachmentWidget(fieldData: fieldData),
                const Divider()
              ],
            );
          });
    });
  }
}

class ChecklistFieldWidget extends HookConsumerWidget {
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
    console("");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String name = fieldData.name ?? "";
    final String description = fieldData.description ?? "";
    final bool isRequired = fieldData.isRequired ?? false;
    final options = fieldData.options ?? [];
    var oldValue = fieldData.value;
    var procedureTemplateState = ref.watch(procedureTemplateProvider.notifier);

    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder<ListOwnOemProcedureTemplates?>(
          stream: procedureTemplateState.stream,
          builder: (context, snapshot) {
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
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                    title: TextView(
                        text: option.name ?? "",
                        textColor: textColorDark,
                        textFontWeight: FontWeight.normal,
                        fontSize: 12),
                    value: isAChildren
                        ? (ref
                                .watch(procedureTemplateProvider.notifier)
                                .state
                                ?.children?[parentIndex]
                                .children?[index]
                                .value
                                ?.contains(option.sId) ??
                            false)
                        : (ref
                                .watch(procedureTemplateProvider.notifier)
                                .state
                                ?.children?[index]
                                .value
                                ?.contains(option.sId) ??
                            false),
                    // Set the actual value based on your logic
                    onChanged: (value) {
                      FocusScope.of(context).unfocus();
                      if (isEditable) {
                        var listOwnOemProcedureTemplates =
                            ref.watch(procedureTemplateProvider.notifier).state;

                        if (isAChildren) {
                          if (listOwnOemProcedureTemplates
                                  ?.children?[parentIndex]
                                  .children?[index]
                                  .value ==
                              null) {
                            listOwnOemProcedureTemplates?.children?[parentIndex]
                                .children?[index].value = [];
                          }
                          if (value ?? false) {
                            listOwnOemProcedureTemplates
                                ?.children?[parentIndex].children?[index].value
                                .add(option.sId);
                          } else {
                            listOwnOemProcedureTemplates
                                ?.children?[parentIndex].children?[index].value
                                .remove(option.sId);
                          }
                          ref
                              .read(procedureTemplateProvider.notifier)
                              .updateValue(listOwnOemProcedureTemplates);

                          ref
                              .watch(procedureFormStateProvider.notifier)
                              .markChanges(
                                  oldValue,
                                  ref
                                      .read(procedureTemplateProvider.notifier)
                                      .state
                                      ?.children?[parentIndex]
                                      .children?[index]
                                      .value);
                        } else {
                          if (listOwnOemProcedureTemplates
                                  ?.children?[index].value ==
                              null) {
                            listOwnOemProcedureTemplates
                                ?.children?[index].value = [];
                          }
                          if (value ?? false) {
                            listOwnOemProcedureTemplates?.children?[index].value
                                .add(option.sId);
                          } else {
                            listOwnOemProcedureTemplates?.children?[index].value
                                .remove(option.sId);
                          }
                          ref
                              .read(procedureTemplateProvider.notifier)
                              .updateValue(listOwnOemProcedureTemplates);

                          ref
                              .watch(procedureFormStateProvider.notifier)
                              .markChanges(
                                  oldValue,
                                  ref
                                      .read(procedureTemplateProvider.notifier)
                                      .state
                                      ?.children?[index]
                                      .value);
                        }
                        ref
                            .watch(procedureFormFinalizedProvider.notifier)
                            .checkIfAllRequiredFieldsAreFilled(ref
                                .watch(procedureTemplateProvider.notifier)
                                .state);
                        setState(() {});
                      }
                    },
                  ),
                AttachmentWidget(fieldData: fieldData),
                const Divider()
              ],
            );
          });
    });
  }
}

class ImageUploaderWidget extends HookConsumerWidget {
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
    console("");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    console("ImageUploaderWidget => ${fieldData.value}");
    final oldValue = fieldData.value;
    var procedureTemplateState = ref.watch(procedureTemplateProvider.notifier);
    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder<ListOwnOemProcedureTemplates?>(
          stream: procedureTemplateState.stream,
          builder: (context, snapshot) {
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
                      FocusScope.of(context).unfocus();
                      if (isEditable) {
                        var listOwnOemProcedureTemplates =
                            ref.watch(procedureTemplateProvider.notifier).state;
                        if (isAChildren) {
                          if (listOwnOemProcedureTemplates
                                  ?.children?[parentIndex]
                                  .children?[index]
                                  .value ==
                              null) {
                            listOwnOemProcedureTemplates?.children?[parentIndex]
                                .children?[index].value = [];
                          }
                        } else {
                          if (listOwnOemProcedureTemplates
                                  ?.children?[index].value ==
                              null) {
                            listOwnOemProcedureTemplates
                                ?.children?[index].value = [];
                          }
                        }
                        ref
                            .read(procedureTemplateProvider.notifier)
                            .updateValue(listOwnOemProcedureTemplates);
                        BottomSheetImageChooserHookModal.show(
                            context,
                            fieldData.name ?? "",
                            index,
                            parentIndex,
                            isAChildren,
                            userValue,
                            procedureId,
                            ref, (p0) {
                          console("BottomSheetImageChooserHookModal on Select");
                          if (isAChildren) {
                            listOwnOemProcedureTemplates
                                ?.children?[parentIndex].children?[index].value
                                .add(p0);

                            ref
                                .read(procedureTemplateProvider.notifier)
                                .updateValue(listOwnOemProcedureTemplates);
                            ref
                                .read(procedureFormStateProvider.notifier)
                                .markChanges(
                                    oldValue ?? [],
                                    listOwnOemProcedureTemplates
                                        ?.children?[parentIndex]
                                        .children?[index]
                                        .value);
                          } else {
                            listOwnOemProcedureTemplates?.children?[index].value
                                .add(p0);

                            ref
                                .read(procedureTemplateProvider.notifier)
                                .updateValue(listOwnOemProcedureTemplates);
                            ref
                                .read(procedureFormStateProvider.notifier)
                                .markChanges(
                                    oldValue ?? [],
                                    listOwnOemProcedureTemplates
                                        ?.children?[index].value);
                          }

                          ref
                              .watch(procedureFormFinalizedProvider.notifier)
                              .checkIfAllRequiredFieldsAreFilled(ref
                                  .watch(procedureTemplateProvider.notifier)
                                  .state);
                          setState(() {});
                        });

                        // BottomSheetImageChooserHookModal.show(context, fieldName, index, parentIndex, isAChildren, currentUser, procedureId, ref, onSelect)

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
                                  text:
                                      "Supported formats: JPEG, PNG; up to 10MB",
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
                    itemCount: isAChildren
                        ? (ref
                                .watch(procedureTemplateProvider.notifier)
                                .state
                                ?.children?[parentIndex]
                                .children?[index]
                                .value
                                ?.length ??
                            0)
                        : (ref
                                .watch(procedureTemplateProvider.notifier)
                                .state
                                ?.children?[index]
                                .value
                                ?.length ??
                            0),
                    itemBuilder: (context, i) {
                      var item;
                      if (isAChildren) {
                        item = ref
                            .watch(procedureTemplateProvider.notifier)
                            .state
                            ?.children?[parentIndex]
                            .children?[index]
                            .value?[i];
                      } else {
                        item = ref
                            .watch(procedureTemplateProvider.notifier)
                            .state
                            ?.children?[index]
                            .value?[i];
                      }

                      var itemUrl = "";
                      try {
                        itemUrl = item["url"] ?? "";
                      } catch (e) {
                        itemUrl = item?.url ?? "";
                      }
                      var file = File(itemUrl);
                      String fileName = basename(file.path);
                      String fileExtension =
                          extension(file.path).replaceAll(".", "");
                      console('Picked File Extension: $fileExtension');

                      return ListTile(
                        leading: SizedBox(
                          height: 36,
                          width: 36,
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
                            FocusScope.of(context).unfocus();
                            //formStateProvider.deleteImageRequestModel(item!);
                            if (isEditable) {
                              if (isAChildren) {
                                ref
                                    .watch(procedureTemplateProvider.notifier)
                                    .state
                                    ?.children?[parentIndex]
                                    .children?[index]
                                    .value
                                    ?.remove(item);
                              } else {
                                ref
                                    .watch(procedureTemplateProvider.notifier)
                                    .state
                                    ?.children?[index]
                                    .value
                                    ?.remove(item);
                              }
                              setState(() {});
                            }
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
                  const Divider()
                ],
              ),
            );
          });
    });
  }
}

class SingleSelectFieldWidget extends HookConsumerWidget {
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
    console("");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = fieldData.options ?? [];
    final oldValue = fieldData.value;
    var procedureTemplateState = ref.watch(procedureTemplateProvider.notifier);

    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder<ListOwnOemProcedureTemplates?>(
          stream: procedureTemplateState.stream,
          builder: (context, snapshot) {
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
                            groupValue: isAChildren
                                ? (ref
                                            .watch(procedureTemplateProvider
                                                .notifier)
                                            .state
                                            ?.children?[parentIndex]
                                            .children?[index]
                                            .value ==
                                        option.sId
                                    ? option
                                    : null)
                                : (ref
                                            .watch(procedureTemplateProvider
                                                .notifier)
                                            .state
                                            ?.children?[index]
                                            .value ==
                                        option.sId
                                    ? option
                                    : null),
                            onChanged: (OptionsModel? value) {
                              FocusScope.of(context).unfocus();
                              if (isEditable) {
                                var listOwnOemProcedureTemplates = ref
                                    .watch(procedureTemplateProvider.notifier)
                                    .state;
                                if (isAChildren) {
                                  if (listOwnOemProcedureTemplates
                                          ?.children?[parentIndex]
                                          .children?[index]
                                          .value ==
                                      null) {
                                    listOwnOemProcedureTemplates
                                        ?.children?[parentIndex]
                                        .children?[index]
                                        .value = [];
                                  }
                                  listOwnOemProcedureTemplates
                                      ?.children?[parentIndex]
                                      .children?[index]
                                      .value = option.sId;
                                  ref
                                      .read(procedureTemplateProvider.notifier)
                                      .updateValue(
                                          listOwnOemProcedureTemplates);
                                  ref
                                      .watch(
                                          procedureFormStateProvider.notifier)
                                      .markChanges(
                                          oldValue,
                                          ref
                                              .read(procedureTemplateProvider
                                                  .notifier)
                                              .state
                                              ?.children?[parentIndex]
                                              .children?[index]
                                              .value);
                                } else {
                                  if (listOwnOemProcedureTemplates
                                          ?.children?[index].value ==
                                      null) {
                                    listOwnOemProcedureTemplates
                                        ?.children?[index].value = [];
                                  }
                                  listOwnOemProcedureTemplates
                                      ?.children?[index].value = option.sId;
                                  ref
                                      .read(procedureTemplateProvider.notifier)
                                      .updateValue(
                                          listOwnOemProcedureTemplates);
                                  ref
                                      .watch(
                                          procedureFormStateProvider.notifier)
                                      .markChanges(
                                          oldValue,
                                          ref
                                              .read(procedureTemplateProvider
                                                  .notifier)
                                              .state
                                              ?.children?[index]
                                              .value);
                                }
                                ref
                                    .watch(
                                        procedureFormFinalizedProvider.notifier)
                                    .checkIfAllRequiredFieldsAreFilled(ref
                                        .watch(
                                            procedureTemplateProvider.notifier)
                                        .state);
                                setState(() {});
                              }
                            },
                          )
                      ],
                    ),
                  ),
                  AttachmentWidget(fieldData: fieldData),
                  const Divider()
                ],
              ),
            );
          });
    });
  }
}

class PartsFieldWidget extends HookConsumerWidget {
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
    console("PartsFieldWidget value => ${fieldData.value}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oldValue = fieldData.value;
    var procedureTemplateState = ref.watch(procedureTemplateProvider.notifier);
    List<PartsModel>? partModelList = [];
    partModelList.addAll(
        inventoryPartListResponse?.listOwnOemInventoryPart?.parts ?? []);

    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder<ListOwnOemProcedureTemplates?>(
          stream: procedureTemplateState.stream,
          builder: (context, snapshot) {
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
                  if (description.isNotEmpty)
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
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    width: context.fullWidth(),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          if (isEditable) {
                            BottomSheetGenericModal.show(
                                context,
                                "Choose Part",
                                partModelList,
                                null,
                                (p0) => p0?.name ?? "", (p0) {
                              console(
                                  "BottomSheetGenericModal -> onSelect: ${p0?.name}");
                              console(
                                  "BottomSheetGenericModal -> onSelect: ${p0?.description}");
                              console(
                                  "BottomSheetGenericModal -> onSelect: ${p0?.image}");
                              console(
                                  "BottomSheetGenericModal -> onSelect: ${p0?.sId}");

                              var listOwnOemProcedureTemplates = ref
                                  .watch(procedureTemplateProvider.notifier)
                                  .state;
                              if (isAChildren) {
                                if (listOwnOemProcedureTemplates
                                        ?.children?[parentIndex]
                                        .children?[index]
                                        .value ==
                                    null) {
                                  listOwnOemProcedureTemplates
                                      ?.children?[parentIndex]
                                      .children?[index]
                                      .value = [];
                                }
                                if (!listOwnOemProcedureTemplates
                                    ?.children?[parentIndex]
                                    .children?[index]
                                    .value
                                    .contains(p0?.sId)) {
                                  listOwnOemProcedureTemplates
                                      ?.children?[parentIndex]
                                      .children?[index]
                                      .value
                                      .add(p0?.sId);
                                }
                                ref
                                    .read(procedureTemplateProvider.notifier)
                                    .updateValue(listOwnOemProcedureTemplates);
                                ref
                                    .watch(procedureFormStateProvider.notifier)
                                    .markChanges(
                                        oldValue,
                                        ref
                                            .read(procedureTemplateProvider
                                                .notifier)
                                            .state
                                            ?.children?[parentIndex]
                                            .children?[index]
                                            .value);
                              } else {
                                if (listOwnOemProcedureTemplates
                                        ?.children?[index].value ==
                                    null) {
                                  listOwnOemProcedureTemplates
                                      ?.children?[index].value = [];
                                }
                                if (!listOwnOemProcedureTemplates
                                    ?.children?[index].value
                                    .contains(p0?.sId)) {
                                  listOwnOemProcedureTemplates
                                      ?.children?[index].value
                                      .add(p0?.sId);
                                }
                                ref
                                    .read(procedureTemplateProvider.notifier)
                                    .updateValue(listOwnOemProcedureTemplates);
                                ref
                                    .watch(procedureFormStateProvider.notifier)
                                    .markChanges(
                                        oldValue,
                                        ref
                                            .read(procedureTemplateProvider
                                                .notifier)
                                            .state
                                            ?.children?[index]
                                            .value);
                              }

                              ref
                                  .watch(
                                      procedureFormFinalizedProvider.notifier)
                                  .checkIfAllRequiredFieldsAreFilled(ref
                                      .watch(procedureTemplateProvider.notifier)
                                      .state);
                              partModelList.removeWhere(
                                  (element) => element.sId == p0?.sId);
                              setState(() {});
                            });
                          }
                        },
                        child: const TextView(
                            text: "Choose Part",
                            textColor: Colors.grey,
                            textFontWeight: FontWeight.normal,
                            fontSize: 14)),
                  ),
                  ListView.separated(
                    itemCount: isAChildren
                        ? (ref
                                .watch(procedureTemplateProvider.notifier)
                                .state
                                ?.children?[parentIndex]
                                .children?[index]
                                .value
                                ?.length ??
                            0)
                        : (ref
                                .watch(procedureTemplateProvider.notifier)
                                .state
                                ?.children?[index]
                                .value
                                ?.length ??
                            0),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      var item;
                      if (isAChildren) {
                        item = ref
                            .watch(procedureTemplateProvider.notifier)
                            .state
                            ?.children?[parentIndex]
                            .children?[index]
                            .value?[i];
                      } else {
                        item = ref
                            .watch(procedureTemplateProvider.notifier)
                            .state
                            ?.children?[index]
                            .value?[i];
                      }

                      PartsModel partModel = PartsModel();
                      inventoryPartListResponse?.listOwnOemInventoryPart?.parts
                          ?.forEach((element) {
                        if (element.sId == item) {
                          partModel.sId = item;
                          partModel.name = element.name;
                          partModel.image = element.image;
                          partModel.description = element.description;
                          partModel.articleNumber = element.articleNumber;
                          partModel.thumbnail = element.thumbnail;
                        }
                      });
                      return ListTile(
                        visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                        leading: SizedBox(
                          height: 24,
                          width: 24,
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              placeholder: (context, url) => const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                  ),
                              errorWidget: (context, url, error) =>
                                  defaultImageBigInventory(context),
                              imageUrl: partModel.image ?? ""),
                        ),
                        title: TextView(
                            text: partModel.name ?? "",
                            textColor: textColorLight,
                            textFontWeight: FontWeight.normal,
                            fontSize: 12),
                        subtitle: TextView(
                            text: partModel.description ?? "",
                            textColor: textColorLight,
                            textFontWeight: FontWeight.normal,
                            fontSize: 10),
                        trailing: GestureDetector(
                          onTap: () {
                            if (isEditable) {
                              var listOwnOemProcedureTemplates = ref
                                  .watch(procedureTemplateProvider.notifier)
                                  .state;

                              if (isAChildren) {
                                listOwnOemProcedureTemplates
                                    ?.children?[parentIndex]
                                    .children?[index]
                                    .value
                                    .remove(item);
                                ref
                                    .read(procedureTemplateProvider.notifier)
                                    .updateValue(listOwnOemProcedureTemplates);
                                ref
                                    .watch(procedureFormStateProvider.notifier)
                                    .markChanges(
                                        oldValue,
                                        ref
                                            .read(procedureTemplateProvider
                                                .notifier)
                                            .state
                                            ?.children?[parentIndex]
                                            .children?[index]
                                            .value);
                              } else {
                                listOwnOemProcedureTemplates
                                    ?.children?[index].value
                                    .remove(item);
                                ref
                                    .read(procedureTemplateProvider.notifier)
                                    .updateValue(listOwnOemProcedureTemplates);
                                ref
                                    .watch(procedureFormStateProvider.notifier)
                                    .markChanges(
                                        oldValue,
                                        ref
                                            .read(procedureTemplateProvider
                                                .notifier)
                                            .state
                                            ?.children?[index]
                                            .value);
                              }
                              var selectedItem = inventoryPartListResponse?.listOwnOemInventoryPart?.parts?.firstWhere(
                                      (element) => element.sId ==  item);
                              partModelList.add(selectedItem!);

                              ref
                                  .watch(
                                      procedureFormFinalizedProvider.notifier)
                                  .checkIfAllRequiredFieldsAreFilled(ref
                                      .watch(procedureTemplateProvider.notifier)
                                      .state);
                              setState(() {});
                            }
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
                  const Divider()
                ],
              ),
            );
          });
    });
  }
}

class MemberFieldWidget extends HookConsumerWidget {
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
    console("");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    console("MemberFieldWidget => ${fieldData.value}");
    final oldValue = fieldData.value;
    var procedureTemplateState = ref.watch(procedureTemplateProvider.notifier);
    List<ListSupportAccounts>? supportAccountList = [];
    supportAccountList
        .addAll(listSupportAccountsResponse?.listOwnOemSupportAccounts ?? []);

    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder<ListOwnOemProcedureTemplates?>(
          stream: procedureTemplateState.stream,
          builder: (context, snapshot) {
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
                    width: context.fullWidth(),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          if (isEditable) {
                            BottomSheetGenericModal.show(
                                context,
                                "Choose Member",
                                supportAccountList,
                                null,
                                (p0) => p0?.name ?? "", (p0) {
                              var listOwnOemProcedureTemplates = ref
                                  .watch(procedureTemplateProvider.notifier)
                                  .state;
                              if (isAChildren) {
                                if (listOwnOemProcedureTemplates
                                        ?.children?[parentIndex]
                                        .children?[index]
                                        .value ==
                                    null) {
                                  listOwnOemProcedureTemplates
                                      ?.children?[parentIndex]
                                      .children?[index]
                                      .value = [];
                                }
                                if (!listOwnOemProcedureTemplates
                                    ?.children?[parentIndex]
                                    .children?[index]
                                    .value
                                    .contains(p0?.sId)) {
                                  listOwnOemProcedureTemplates
                                      ?.children?[parentIndex]
                                      .children?[index]
                                      .value
                                      .add(p0?.sId);
                                }
                                ref
                                    .read(procedureTemplateProvider.notifier)
                                    .updateValue(listOwnOemProcedureTemplates);
                                ref
                                    .watch(procedureFormStateProvider.notifier)
                                    .markChanges(
                                        oldValue,
                                        ref
                                            .read(procedureTemplateProvider
                                                .notifier)
                                            .state
                                            ?.children?[parentIndex]
                                            .children?[index]
                                            .value);
                              } else {
                                if (listOwnOemProcedureTemplates
                                        ?.children?[index].value ==
                                    null) {
                                  listOwnOemProcedureTemplates
                                      ?.children?[index].value = [];
                                }
                                if (!listOwnOemProcedureTemplates
                                    ?.children?[index].value
                                    .contains(p0?.sId)) {
                                  listOwnOemProcedureTemplates
                                      ?.children?[index].value
                                      .add(p0?.sId);
                                }
                                ref
                                    .read(procedureTemplateProvider.notifier)
                                    .updateValue(listOwnOemProcedureTemplates);
                                ref
                                    .watch(procedureFormStateProvider.notifier)
                                    .markChanges(
                                        oldValue,
                                        ref
                                            .read(procedureTemplateProvider
                                                .notifier)
                                            .state
                                            ?.children?[index]
                                            .value);
                              }
                              ref
                                  .watch(
                                      procedureFormFinalizedProvider.notifier)
                                  .checkIfAllRequiredFieldsAreFilled(ref
                                      .watch(procedureTemplateProvider.notifier)
                                      .state);

                              supportAccountList.removeWhere(
                                  (element) => element.sId == p0?.sId);

                              setState(() {});
                            });
                          }
                        },
                        child: const TextView(
                            text: "Choose Member",
                            textColor: Colors.grey,
                            textFontWeight: FontWeight.normal,
                            fontSize: 14)),
                  ),
                  ListView.separated(
                    itemCount: isAChildren
                        ? (ref
                                .watch(procedureTemplateProvider.notifier)
                                .state
                                ?.children?[parentIndex]
                                .children?[index]
                                .value
                                ?.length ??
                            0)
                        : (ref
                                .watch(procedureTemplateProvider.notifier)
                                .state
                                ?.children?[index]
                                .value
                                ?.length ??
                            0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      var item;
                      if (isAChildren) {
                        item = ref
                            .watch(procedureTemplateProvider.notifier)
                            .state
                            ?.children?[parentIndex]
                            .children?[index]
                            .value?[i];
                      } else {
                        item = ref
                            .watch(procedureTemplateProvider.notifier)
                            .state
                            ?.children?[index]
                            .value?[i];
                      }
                      ListSupportAccounts model = ListSupportAccounts();
                      listSupportAccountsResponse?.listOwnOemSupportAccounts
                          ?.forEach((element) {
                        if (element.sId == item) {
                          model.sId = item;
                          model.name = element.name;
                          model.username = element.username;
                        }
                      });
                      return ListTile(
                        visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                        leading: SizedBox(
                          height: 24,
                          width: 24,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/images/picture_circle.svg",
                                color: textColorDark,
                              ),
                              Text(
                                getInitials(model.name?.isNotEmpty == true
                                        ? getInitials(model.name ?? "")
                                        : "U")
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontFamily: 'Manrope'),
                              )
                            ],
                          ),
                        ),
                        title: TextView(
                            text: model.name ?? "",
                            textColor: textColorLight,
                            textFontWeight: FontWeight.normal,
                            fontSize: 12),
                        trailing: GestureDetector(
                          onTap: () {
                            if (isEditable) {
                              var listOwnOemProcedureTemplates = ref
                                  .watch(procedureTemplateProvider.notifier)
                                  .state;
                              if (isAChildren) {
                                listOwnOemProcedureTemplates
                                    ?.children?[parentIndex]
                                    .children?[index]
                                    .value
                                    .remove(item);
                                ref
                                    .read(procedureTemplateProvider.notifier)
                                    .updateValue(listOwnOemProcedureTemplates);
                                ref
                                    .watch(procedureFormStateProvider.notifier)
                                    .markChanges(
                                        oldValue,
                                        ref
                                            .read(procedureTemplateProvider
                                                .notifier)
                                            .state
                                            ?.children?[parentIndex]
                                            .children?[index]
                                            .value);
                                ref
                                    .watch(
                                        procedureFormFinalizedProvider.notifier)
                                    .checkIfAllRequiredFieldsAreFilled(ref
                                        .watch(
                                            procedureTemplateProvider.notifier)
                                        .state);
                              } else {
                                listOwnOemProcedureTemplates
                                    ?.children?[index].value
                                    .remove(item);
                                ref
                                    .read(procedureTemplateProvider.notifier)
                                    .updateValue(listOwnOemProcedureTemplates);
                                ref
                                    .watch(procedureFormStateProvider.notifier)
                                    .markChanges(
                                        oldValue,
                                        ref
                                            .read(procedureTemplateProvider
                                                .notifier)
                                            .state
                                            ?.children?[index]
                                            .value);
                                ref
                                    .watch(
                                        procedureFormFinalizedProvider.notifier)
                                    .checkIfAllRequiredFieldsAreFilled(ref
                                        .watch(
                                            procedureTemplateProvider.notifier)
                                        .state);
                              }
                              var selectedItem = listSupportAccountsResponse?.listOwnOemSupportAccounts?.firstWhere(
                                      (element) => element.sId ==  item);
                              supportAccountList.add(selectedItem!);
                              setState(() {});
                            }
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
                  const Divider()
                ],
              ),
            );
          });
    });
  }
}

class TableFieldWidget extends HookConsumerWidget {
  final ChildrenModel fieldData;
  final BuildContext context;
  final bool isEditable;
  final int index;
  final int parentIndex;
  final bool isAChildren;

  const TableFieldWidget(
      {super.key,
      required this.fieldData,
      required this.context,
      required this.index,
      required this.parentIndex,
      required this.isAChildren,
      required this.isEditable});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var procedureTemplateState = ref.watch(procedureTemplateProvider.notifier);

    if (fieldData.value == null) {
      Map<String, dynamic> mapItem = {};
      var listOwnOemProcedureTemplates =
          ref.watch(procedureTemplateProvider.notifier).state;

      if (isAChildren) {
        if (listOwnOemProcedureTemplates
                ?.children?[parentIndex].children?[index].value ==
            null) {
          listOwnOemProcedureTemplates
              ?.children?[parentIndex].children?[index].value = [];
        }
        listOwnOemProcedureTemplates
            ?.children?[parentIndex].children?[index].tableOption?.columns
            ?.forEach((element) {
          var item = {element.sId ?? "": element.value ?? ""};
          mapItem.addAll(item);
        });
        listOwnOemProcedureTemplates
            ?.children?[parentIndex].children?[index].value
            .add(mapItem);
      } else {
        if (listOwnOemProcedureTemplates?.children?[index].value == null) {
          listOwnOemProcedureTemplates?.children?[index].value = [];
        }
        listOwnOemProcedureTemplates?.children?[index].tableOption?.columns
            ?.forEach((element) {
          var item = {element.sId ?? "": element.value ?? ""};
          mapItem.addAll(item);
        });
        listOwnOemProcedureTemplates?.children?[index].value.add(mapItem);
      }
    }

    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder<ListOwnOemProcedureTemplates?>(
          stream: procedureTemplateState.stream,
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                TextView(
                    text:
                        "${fieldData.name ?? ""} ${fieldData.isRequired ?? false ? "*" : ""}",
                    textColor: textColorLight,
                    textFontWeight: FontWeight.normal,
                    fontSize: 14),
                if (fieldData.description != null)
                  Column(
                    children: [
                      const SizedBox(
                        height: 4,
                      ),
                      TextView(
                          text: fieldData.description ?? "",
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
                          itemCount: isAChildren
                              ? (ref
                                      .watch(procedureTemplateProvider.notifier)
                                      .state
                                      ?.children?[parentIndex]
                                      .children?[index]
                                      .value
                                      ?.length ??
                                  0)
                              : (ref
                                      .watch(procedureTemplateProvider.notifier)
                                      .state
                                      ?.children?[index]
                                      .value
                                      ?.length ??
                                  0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, mainIndex) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                  decoration: BoxDecoration(
                                    color: chatBubbleSenderClosed,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextView(
                                          text: "Row ${mainIndex + 1}",
                                          textColor: textColorLight,
                                          textFontWeight: FontWeight.normal,
                                          fontSize: 12),
                                      GestureDetector(
                                          onTap: () {
                                            if (isEditable) {
                                              var listOwnOemProcedureTemplates =
                                                  ref
                                                      .watch(
                                                          procedureTemplateProvider
                                                              .notifier)
                                                      .state;

                                              if (isAChildren) {
                                                listOwnOemProcedureTemplates
                                                    ?.children?[parentIndex]
                                                    .children?[index]
                                                    .value
                                                    .removeAt(mainIndex);
                                                ref
                                                    .read(
                                                        procedureTemplateProvider
                                                            .notifier)
                                                    .updateValue(
                                                        listOwnOemProcedureTemplates);
                                              } else {
                                                listOwnOemProcedureTemplates
                                                    ?.children?[index].value
                                                    .removeAt(mainIndex);
                                                ref
                                                    .read(
                                                        procedureTemplateProvider
                                                            .notifier)
                                                    .updateValue(
                                                        listOwnOemProcedureTemplates);
                                              }
                                              setState(() {});
                                            }
                                          },
                                          child: SvgPicture.asset(
                                              "assets/images/ic-delete.svg"))
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: isAChildren
                                      ? (ref
                                              .watch(procedureTemplateProvider
                                                  .notifier)
                                              .state
                                              ?.children?[parentIndex]
                                              .children?[index]
                                              .tableOption
                                              ?.columns
                                              ?.length ??
                                          0)
                                      : (ref
                                              .watch(procedureTemplateProvider
                                                  .notifier)
                                              .state
                                              ?.children?[index]
                                              .tableOption
                                              ?.columns
                                              ?.length ??
                                          0),
                                  itemBuilder: (context, columnIndex) {
                                    var value;
                                    ColumnsModel? columnItem;
                                    if (isAChildren) {
                                      columnItem = ref
                                          .watch(procedureTemplateProvider
                                              .notifier)
                                          .state
                                          ?.children?[parentIndex]
                                          .children?[index]
                                          .tableOption
                                          ?.columns?[columnIndex];
                                      value = ref
                                          .watch(procedureTemplateProvider
                                              .notifier)
                                          .state
                                          ?.children?[parentIndex]
                                          .children?[index]
                                          .value[mainIndex];
                                    } else {
                                      columnItem = ref
                                          .watch(procedureTemplateProvider
                                              .notifier)
                                          .state
                                          ?.children?[index]
                                          .tableOption
                                          ?.columns?[columnIndex];
                                      value = ref
                                          .watch(procedureTemplateProvider
                                              .notifier)
                                          .state
                                          ?.children?[index]
                                          .value[mainIndex];
                                    }
                                    console(
                                        "TableFieldWidget COLUMN - heading  => ${columnItem?.heading}");
                                    console(
                                        "TableFieldWidget value => ${value?[columnItem?.sId]?.toString()} --- ${columnItem?.sId}");
                                    return Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 8, 16, 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: TextView(
                                                  text:
                                                      columnItem?.heading ?? "",
                                                  textColor: Colors.black,
                                                  textFontWeight:
                                                      FontWeight.normal,
                                                  fontSize: 12)),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: TextFormField(
                                                enabled: isEditable,
                                                //controller: rows[mainIndex][childIndex],
                                                initialValue:
                                                    value[columnItem?.sId] ??
                                                        "",
                                                decoration:
                                                    const InputDecoration(
                                                        hintText: '-',
                                                        border:
                                                            InputBorder.none),
                                                onChanged: (v) {
                                                  console("onChanged --- $v");
                                                  if (isAChildren) {
                                                    ref
                                                            .watch(
                                                                procedureTemplateProvider
                                                                    .notifier)
                                                            .state
                                                            ?.children?[parentIndex]
                                                            .children?[index]
                                                            .value[mainIndex]
                                                        [columnItem?.sId] = v;
                                                  } else {
                                                    ref
                                                            .watch(
                                                                procedureTemplateProvider
                                                                    .notifier)
                                                            .state
                                                            ?.children?[index]
                                                            .value[mainIndex]
                                                        [columnItem?.sId] = v;
                                                  }
                                                  //ref.watch(procedureTemplateProvider.notifier).state?.children?[parentIndex].children?[index].value[mainIndex][columnItem?.sId] = value;
                                                  ref
                                                      .watch(
                                                          procedureFormStateProvider
                                                              .notifier)
                                                      .markChanges(
                                                          value[columnItem?.sId
                                                                  .toString()]
                                                              .toString(),
                                                          v);
                                                  ref
                                                      .watch(
                                                          procedureFormFinalizedProvider
                                                              .notifier)
                                                      .checkIfAllRequiredFieldsAreFilled(ref
                                                          .watch(
                                                              procedureTemplateProvider
                                                                  .notifier)
                                                          .state);
                                                },
                                              )),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              ],
                            );
                          }),
                      const Divider(),
                      GestureDetector(
                        onTap: () {
                          if (isEditable) {
                            var listOwnOemProcedureTemplates = ref
                                .watch(procedureTemplateProvider.notifier)
                                .state;
                            Map<String, dynamic> mapItem = {};

                            if (isAChildren) {
                              if (listOwnOemProcedureTemplates
                                      ?.children?[parentIndex]
                                      .children?[index]
                                      .value ==
                                  null) {
                                listOwnOemProcedureTemplates
                                    ?.children?[parentIndex]
                                    .children?[index]
                                    .value = [];
                              }
                              listOwnOemProcedureTemplates
                                  ?.children?[parentIndex]
                                  .children?[index]
                                  .tableOption
                                  ?.columns
                                  ?.forEach((element) {
                                var item = {
                                  element.sId ?? "": element.value ?? ""
                                };
                                mapItem.addAll(item);
                              });

                              listOwnOemProcedureTemplates
                                  ?.children?[parentIndex]
                                  .children?[index]
                                  .value
                                  .add(mapItem);
                              ref
                                  .watch(procedureFormStateProvider.notifier)
                                  .markChanges(
                                      "",
                                      ref
                                          .read(procedureTemplateProvider
                                              .notifier)
                                          .state
                                          ?.children?[parentIndex]
                                          .children?[index]
                                          .value);
                            } else {
                              if (listOwnOemProcedureTemplates
                                      ?.children?[index].value ==
                                  null) {
                                listOwnOemProcedureTemplates
                                    ?.children?[index].value = [];
                              }
                              listOwnOemProcedureTemplates
                                  ?.children?[index].tableOption?.columns
                                  ?.forEach((element) {
                                var item = {
                                  element.sId ?? "": element.value ?? ""
                                };
                                mapItem.addAll(item);
                              });

                              listOwnOemProcedureTemplates
                                  ?.children?[index].value
                                  .add(mapItem);
                              ref
                                  .watch(procedureFormStateProvider.notifier)
                                  .markChanges(
                                      "",
                                      ref
                                          .read(procedureTemplateProvider
                                              .notifier)
                                          .state
                                          ?.children?[index]
                                          .value);
                            }
                            ref
                                .watch(procedureFormFinalizedProvider.notifier)
                                .checkIfAllRequiredFieldsAreFilled(ref
                                    .watch(procedureTemplateProvider.notifier)
                                    .state);
                            setState(() {});
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
                AttachmentWidget(fieldData: fieldData),
                const Divider(),
              ],
            );
          });
    });
  }
}

class AttachmentWidget extends StatelessWidget {
  final ChildrenModel fieldData;

  const AttachmentWidget({super.key, required this.fieldData});

  @override
  Widget build(BuildContext context) {
    if (fieldData.attachments?.isNotEmpty == true) {
      return Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Set dividerColor to transparent
        ),
        child: MediaQuery.removePadding(
          removeTop: true,
          removeBottom: true,
          context: context,
          child: ExpansionTile(
            trailing: const SizedBox(),
            shape: const Border(),
            childrenPadding: EdgeInsets.zero,
            tilePadding: EdgeInsets.zero,
            title: Container(
              padding: EdgeInsets.only(top: 0, bottom: 0),
              child: const Row(
                children: [
                  TextView(
                      text: "View Attachments",
                      textColor: Colors.black,
                      textFontWeight: FontWeight.normal,
                      fontSize: 12),
                  Icon(Icons.keyboard_arrow_down)
                ],
              ),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: fieldData.attachments?.length,
                itemBuilder: (context, index) {
                  var item = fieldData.attachments?[index];

                  return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
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
                    child: Row(
                      children: [
                        Icon(
                          Icons.document_scanner,
                          color: textColorLight,
                          size: 36,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextView(
                                text: item?.name ?? "",
                                textColor: textColorLight,
                                textFontWeight: FontWeight.bold,
                                fontSize: 12,
                                isEllipsis: true,
                              ),
                              TextView(
                                  text:
                                      "${getFileType(item?.type ?? "")} • ${getFileSizeInKBs(item?.size ?? "")}",
                                  textColor: textColorLight,
                                  textFontWeight: FontWeight.normal,
                                  fontSize: 12),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                  return ListTile(
                    onTap: () {
                      FocusScope.of(context).unfocus();
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
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    contentPadding: EdgeInsets.zero,
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
              ),
              const SizedBox(
                width: 16,
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox();
  }
}

class ActionButtons extends HookConsumerWidget {
  final String templatesId;
  final void Function(bool) refreshCallback;
  final ListOwnOemProcedureTemplates? templates;

  const ActionButtons(
      {super.key,
      required this.templatesId,
      required this.templates,
      required this.refreshCallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final procedureTemplateState =
        ref.watch(procedureTemplateProvider.notifier);
    final procedureFormState = ref.watch(procedureFormStateProvider.notifier);
    final procedureFormFinalizedState =
        ref.watch(procedureFormFinalizedProvider.notifier);
    final procedureSignatureState =
        ref.watch(procedureSignatureStateProvider.notifier);
    return StreamBuilder<bool?>(
        stream: procedureFormState.stream,
        builder: (context, snapshot) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: CustomElevatedButton(
                        backgroundColor: visitContainerColor,
                        textColor:
                            ref.watch(procedureFormStateProvider.notifier).state
                                ? primaryColor
                                : Colors.grey,
                        borderRadius: 8,
                        title: "Save as Draft",
                        fontSize: 14,
                        isValid: ref
                            .watch(procedureFormStateProvider.notifier)
                            .state,
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          console(
                              "SaveAsDraft => ${identical(templates, procedureTemplateState.state)}");
                          console(
                              "SaveAsDraft => ${templates == procedureTemplateState.state}");

                          procedureTemplateState.state?.children
                              ?.forEach((element) {
                            console(
                                "SaveAsDraft element => ${element.name} -- ${element.value} -- ${element.isRequired}");
                            element.children?.forEach((child) {
                              console(
                                  "SaveAsDraft child => ${child.name} -- ${child.value} -- ${child.isRequired}");
                            });
                          });

                          var isConnected = await isConnectedToNetwork();
                          if (isConnected && context.mounted) {
                            context.showCustomDialog();
                            var sId = procedureTemplateState.state?.sId ?? "";
                            var childrenModel =
                                procedureTemplateState.state?.children;
                            var signatureModel =
                                procedureTemplateState.state?.signatures;
                            List<SignatureRequestModel> signatureRequestList =
                                [];
                            signatureModel?.forEach((element) {
                              var model = SignatureRequestModel(
                                id: element.sId,
                                name: element.name,
                                date: element.date,
                                signature: element.signatureUrl,
                              );
                              signatureRequestList.add(model);
                            });
                            var result = await ProcedureViewModel()
                                .saveAsDraftOemProcedure(
                                    sId, childrenModel, signatureRequestList);
                            if (context.mounted) Navigator.pop(context);
                            result.join(
                                (failed) =>
                                    {console("failed => ${failed.exception}")},
                                (loaded) => {
                                      console("loaded => ${loaded.data}"),
                                      refreshCallback(true),
                                      context.showSuccessSnackBar(
                                          "Your changes are saved successfully")
                                    },
                                (loading) => {
                                      console("loading => "),
                                    });
                          } else {
                            refreshCallback(true);
                            //templates?.signatures = signatureRequestModel;
                          }
                        })),
                const SizedBox(
                  width: 16,
                ),
                StreamBuilder<bool>(
                    stream: procedureSignatureState.stream,
                    builder: (context, snapshot) {
                      return StreamBuilder<bool>(
                          stream: procedureFormFinalizedState.stream,
                          builder: (context, snapshot) {
                            console(
                                "message => ${templates?.state != "FINALIZED"} --- ${ref.watch(procedureSignatureStateProvider.notifier).state} ---- ${ref.watch(procedureFormStateProvider.notifier).state}");
                            return Expanded(
                                child: CustomElevatedButton(
                                    textColor: Colors.white,
                                    borderRadius: 8,
                                    fontSize: 14,
                                    isValid: (ref
                                                .watch(
                                                    procedureSignatureStateProvider
                                                        .notifier)
                                                .state ||
                                            templates?.signatures?.isEmpty ==
                                                true) &&
                                        ref
                                            .watch(
                                                procedureFormFinalizedProvider
                                                    .notifier)
                                            .state,
                                    title: "Finalize",
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      var isConnected =
                                          await isConnectedToNetwork();
                                      if (isConnected && context.mounted) {
                                        context.showCustomDialog();
                                        var sId =
                                            procedureTemplateState.state?.sId ??
                                                "";
                                        var childrenModel =
                                            procedureTemplateState
                                                .state?.children;
                                        var signatureModel =
                                            procedureTemplateState
                                                .state?.signatures;
                                        List<SignatureRequestModel>
                                            signatureRequestList = [];
                                        signatureModel?.forEach((element) {
                                          var model = SignatureRequestModel(
                                            id: element.sId,
                                            name: element.name,
                                            date: element.date,
                                            signature: element.signatureUrl,
                                          );
                                          signatureRequestList.add(model);
                                        });
                                        var result = await ProcedureViewModel()
                                            .finalizeOemProcedure(
                                                sId,
                                                childrenModel,
                                                signatureRequestList);
                                        if (context.mounted) {
                                          result.join(
                                              (failed) => {
                                                    Navigator.pop(context),
                                                    console(
                                                        "failed => ${failed.exception}")
                                                  },
                                              (loaded) => {
                                                    console(
                                                        "loaded => ${loaded.data}"),
                                                    refreshCallback(false),
                                                    // refreshCallback(),
                                                  },
                                              (loading) => {
                                                    console("loading => "),
                                                  });
                                        }
                                      }
                                    }));
                          });
                    }),
              ],
            ),
          );
        });
  }
}

DateTime convertStringToDateTime(String? value) {
  console("convertStringToDateTime => $value");
  if (value != null) {
    String format = "yyyy-MM-dd'T'hh:mm:ss.SSS";
    DateFormat dateFormat = DateFormat(format);
    return dateFormat.parse(value);
  } else {
    return DateTime.now();
  }
}

String convertStringDateToDDMMYYYY(String? value) {
  if (value != null) {
    // Parse the string into a DateTime object
    DateTime dateTime = DateTime.parse(value);

    // Create a DateFormat object for the desired output format
    DateFormat outputFormat = DateFormat("dd-MM-yyyy");

    // Format the DateTime object using the desired format
    return outputFormat.format(dateTime);
  }
  return "DD-MM-YYYY";
}
