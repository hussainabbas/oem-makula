import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/providers.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/procedure_viewmodel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../../../../helper/model/safe_sign_s3_response.dart';
import '../../../../../../helper/utils/colors.dart';
import '../../../../../../helper/utils/utils.dart';
import '../../../../../../main.dart';
import '../../../../../widgets/custom_elevated_button.dart';
import '../../../../../widgets/makula_text_view.dart';

class SignatureHooksProcedureScreen extends HookConsumerWidget {
  final int index;
  final CurrentUser? currentUser;
  final String procedureId;
  final VoidCallback onSelect;

  const SignatureHooksProcedureScreen(
      {super.key,
      required this.index,
      required this.currentUser,
        required this.onSelect,
      required this.procedureId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));

    final procedureTemplateState =
        ref.watch(procedureTemplateProvider.notifier);
    final SignatureController controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,

    );


    uploadImageOnBucket(
      SafeSigns3Response safeSigns3Response,
      File file,
      String fileName,
      String fileExtension,
    ) async {
      context.showCustomDialog();
      var loggedInResponse =
          await appDatabase?.loginMobileDao.getLoginResponseFromDb();
      List<int> bytes = await file.readAsBytes();
      var headers = {
        'x-makula-token': loggedInResponse?.token ?? "",
        'x-makula-refresh-token': loggedInResponse?.refreshToken ?? "",
        'x-makula-auth-request-type': 'LOCAL_STORAGE',
        'Content-Type': 'image/jpeg'
      };
      var request = http.Request('PUT',
          Uri.parse(safeSigns3Response.sSafeSignS3?.signedRequest ?? ""));
      request.bodyBytes = bytes;

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (context.mounted) Navigator.pop(context);
      if (response.statusCode == 200 && context.mounted) {
        console('PUT request successful! Response: ${response.statusCode}');
        // Provider.of<ProcedureProvider>(context, listen: false).signatureModel?[widget.index].signature = safeSigns3Response.sSafeSignS3?.url;

        var listOwnOemProcedureTemplates =
            ref.watch(procedureTemplateProvider.notifier).state;

        var signature = listOwnOemProcedureTemplates?.signatures?[index];
        signature?.signatureUrl = safeSigns3Response.sSafeSignS3?.url;

        ref
            .watch(procedureTemplateProvider.notifier)
            .updateValue(listOwnOemProcedureTemplates);

        Navigator.pop(context);
        onSelect();
        // var selectedSignatureModel = Provider.of<ProcedureProvider>(context, listen: false).signatureModel?[widget.index];
        // var model = SignatureRequestModel(
        //     name: selectedSignatureModel?.name,
        //     date: selectedSignatureModel?.date,
        //     id: selectedSignatureModel?.id,
        //     signature: safeSigns3Response.sSafeSignS3?.url);
        //
        // Provider.of<ProcedureProvider>(context,
        //     listen: false).updateSignature(model, widget.index);
      } else {
        console(response.reasonPhrase.toString());
      }
    }

    observerUploadImageS3(SafeSigns3Response safeSigns3Response,
        String fileName, String fileExtension, File file) {
      uploadImageOnBucket(safeSigns3Response, file, fileName, fileExtension);
    }

    uploadImagesToS3(File file) async {
      var isConnected = await isConnectedToNetwork();
      if (isConnected) {
        String fileName = basename(file.path);
        console('Picked File Name: $fileName');
        // Get file extension
        String fileExtension = extension(file.path).replaceAll(".", "");
        console('Picked File Extension: $fileExtension');
        var type =
            "oem/${currentUser?.organizationName}/procedures/${procedureId}/file";
        var result = await ProcedureViewModel()
            .safeSignS3("Signature-sign", "image/$fileExtension", true, type);
        result.join(
            (failed) => {console("failed => ${failed.exception}")},
            (loaded) => {
                  observerUploadImageS3(
                      loaded.data, fileName, fileExtension, file)
                },
            (loading) => {
                  console("loading => "),
                });
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: lightGray,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                  text: "Provide Signature",
                  textColor: textColorDark,
                  textFontWeight: FontWeight.w500,
                  fontSize: 14),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: lightGray),
                      child: Signature(
                        controller: controller,
                        backgroundColor: Colors.transparent,
                      ))),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        flex: 1,
                        child: CustomElevatedButton(
                            backgroundColor: visitContainerColor,
                            textColor: primaryColor,
                            borderRadius: 8,
                            title: "Reset",
                            onPressed: () {
                              controller.clear();
                            })),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                        flex: 2,
                        child: CustomElevatedButton(
                            backgroundColor: primaryColor,
                            textColor: Colors.white,
                            borderRadius: 8,
                            title: "Save Signature",
                            onPressed: () async {
                              if (controller.isEmpty) {
                                context.showErrorSnackBar("Please add your signature to proceed");
                                return;
                              }
                              var signature = await controller.toImage();
                              // Convert Image to ByteData
                              final ByteData? byteData = await signature
                                  ?.toByteData(format: ImageByteFormat.png);
                              final Uint8List? uint8List =
                                  byteData?.buffer.asUint8List();

                              // Get the temporary directory using path_provider
                              final Directory tempDir =
                                  await getTemporaryDirectory();
                              final String tempPath = tempDir.path;

                              // Check for null and use the null-aware spread operator
                              final List<int> byteList =
                                  uint8List != null ? [...uint8List] : [];

                              // Create a temporary file
                              final File tempFile =
                                  File('$tempPath/signature_image.png');

                              // Write the image data to the file
                              File signatureImage =
                                  await tempFile.writeAsBytes(byteList);
                              uploadImagesToS3(signatureImage);
                              console("signatureImage => $signatureImage");
                            })),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
