
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/safe_sign_s3_response.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/procedure_viewmodel.dart';
import 'package:makula_oem/views/widgets/custom_elevated_button.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import '../../../../../../helper/model/signature_model.dart';
import '../../../../../../main.dart';
import '../provider/procedure_provider.dart';
import 'package:http/http.dart' as http;

class SignatureProcedureScreen extends StatefulWidget {
  final int index;
  final CurrentUser? currentUser;
  final String procedureId;
  const SignatureProcedureScreen({super.key, required this.index, required this.currentUser, required this.procedureId});

  @override
  State<SignatureProcedureScreen> createState() =>
      _SignatureProcedureScreenState();
}

class _SignatureProcedureScreenState extends State<SignatureProcedureScreen> {

  @override
  Widget build(BuildContext context) { 
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));
    final SignatureController controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,

    );

    uploadImageOnBucket(
        SafeSigns3Response safeSigns3Response,
        File file, String fileName, String fileExtension,) async {
      context.showCustomDialog();
      var loggedInResponse = await appDatabase?.loginMobileDao.getLoginResponseFromDb();
      List<int> bytes = await file.readAsBytes();
      var headers = {
        'x-makula-token': loggedInResponse?.token ?? "",
        'x-makula-refresh-token': loggedInResponse?.refreshToken ?? "",
        'x-makula-auth-request-type': 'LOCAL_STORAGE',
        'Content-Type': 'image/jpeg'
      };
      var request = http.Request('PUT', Uri.parse(safeSigns3Response.sSafeSignS3?.signedRequest ?? ""));
      request.bodyBytes = bytes;

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      Navigator.pop(context);
      if (response.statusCode == 200 && context.mounted) {
            console(
                'PUT request successful! Response: ${response.statusCode}');
            // Provider.of<ProcedureProvider>(context, listen: false).signatureModel?[widget.index].signature = safeSigns3Response.sSafeSignS3?.url;
            Navigator.pop(context);

            var selectedSignatureModel = Provider.of<ProcedureProvider>(context, listen: false).signatureModel?[widget.index];
            var model = SignatureRequestModel(
                name: selectedSignatureModel?.name,
                date: selectedSignatureModel?.date,
                id: selectedSignatureModel?.id,
                signature: safeSigns3Response.sSafeSignS3?.url);

            Provider.of<ProcedureProvider>(context,
                listen: false).updateSignature(model, widget.index);
      }
      else {
        console(response.reasonPhrase.toString());
      }
    }

    observerUploadImageS3(SafeSigns3Response safeSigns3Response, String fileName, String fileExtension, File file) {
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
        var type = "oem/${widget.currentUser?.organizationName}/procedures/${widget.procedureId}/file";
        var result = await ProcedureViewModel().safeSignS3("Signature-sign", "image/$fileExtension", true, type);
        result.join(
                (failed) => {console("failed => ${failed.exception}")},
                (loaded) => {observerUploadImageS3(loaded.data, fileName, fileExtension, file)},
                (loading) => {
              console("loading => "),
            });
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: lightGray,),
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
              const SizedBox(height: 16,),
              Expanded(child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: lightGray
                  ),
                  child: Signature(controller: controller,backgroundColor: Colors.transparent, ))),

              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
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
                        child: CustomElevatedButton(
                            backgroundColor:  primaryColor,
                            textColor: Colors.white,
                            borderRadius: 8,
                            title: "Save Signature",
                            onPressed: () async {
                              var signature = await controller.toImage();
                              // Convert Image to ByteData
                              final ByteData? byteData = await signature?.toByteData(format: ImageByteFormat.png);
                              final Uint8List? uint8List = byteData?.buffer.asUint8List();

                              // Get the temporary directory using path_provider
                              final Directory tempDir = await getTemporaryDirectory();
                              final String tempPath = tempDir.path;

                              // Check for null and use the null-aware spread operator
                              final List<int> byteList = uint8List != null ? [...uint8List] : [];


                              // Create a temporary file
                              final File tempFile = File('$tempPath/signature_image.png');

                              // Write the image data to the file
                              File signatureImage = await tempFile.writeAsBytes(byteList);
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
