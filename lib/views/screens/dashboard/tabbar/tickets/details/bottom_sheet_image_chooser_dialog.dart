
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:makula_oem/helper/model/safe_sign_s3_response.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/context_function.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/procedure_viewmodel.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/procedure_provider.dart';
import 'package:makula_oem/views/widgets/custom_elevated_button.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../../../../../../helper/model/get_current_user_details_model.dart';
import '../../../../../../main.dart';

class BottomSheetImageChooserModal {
  static void show(
      BuildContext context,
      String fieldName,
      int index,
      int parentIndex,
      bool isAChildren,
      CurrentUser? currentUser,
      String procedureId) {
    showModalBottomSheet(
        barrierLabel: "Upload Images",
        barrierColor: Colors.black.withOpacity(0.5),
        context: context,
        builder: (BuildContext context) {
          final formStateProvider =
              Provider.of<ProcedureProvider>(context, listen: false);
          void pickImageFromGallery() async {
            final pickedFile =
                await ImagePicker().pickImage(source: ImageSource.gallery);
            if (pickedFile != null && context.mounted) {
              formStateProvider.setImageFieldValue(fieldName, pickedFile.path);
            }
          }

          void takePhoto(BuildContext context) async {
            final pickedFile =
                await ImagePicker().pickImage(source: ImageSource.camera);

            if (pickedFile != null && context.mounted) {
              formStateProvider.setImageFieldValue(fieldName, pickedFile.path);
            }
          }

          uploadImageOnBucket(
              SafeSigns3Response safeSigns3Response,
              File file,
              String fileName,
              String fileExtension,
              int index,
              int totalLength) async {
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

            if (response.statusCode == 200 && context.mounted) {
                  console(
                      'PUT request successful! Response: ${response.statusCode}');

                  formStateProvider.setUploadedImageList(
                      safeSigns3Response, fieldName);
                  console("observerUploadImageS3 = $index ---- $totalLength");
                  var fileSize = file.lengthSync();
                  Provider.of<ProcedureProvider>(context, listen: false)
                      .setImageRequestModel(ImageRequestModel(
                          size: fileSize,
                          name: fileName,
                          url: safeSigns3Response.sSafeSignS3?.url,
                          type: fileExtension));

                  if (isAChildren) {
                    Provider.of<ProcedureProvider>(context, listen: false)
                            .myProcedureRequest
                            ?.children?[parentIndex]
                            .children?[index]
                            .value =
                        Provider.of<ProcedureProvider>(context, listen: false)
                            .imageRequestModel;
                  } else {
                    Provider.of<ProcedureProvider>(context, listen: false)
                            .myProcedureRequest
                            ?.children?[index]
                            .value =
                        Provider.of<ProcedureProvider>(context, listen: false)
                            .imageRequestModel;
                  }
                  Navigator.pop(context);
                  if (index == (totalLength - 1)) {
                    Navigator.pop(context);
                  }
                  formStateProvider.deleteImageFieldValue(file.path);
            }
            else {
              console(response.reasonPhrase.toString());
            }
          }

          observerUploadImageS3(
              SafeSigns3Response safeSigns3Response,
              File file,
              String fileName,
              String fileExtension,
              int index,
              int totalLength) {
            uploadImageOnBucket(safeSigns3Response, file, fileName,
                fileExtension, index, totalLength);
          }

          uploadImagesToS3() async {
            var isConnected = await isConnectedToNetwork();
            if (isConnected) {
              var list = formStateProvider.selectedImageList ?? [];

              for (int index = 0; index < list.length; index++) {
                console("uploadImagesToS3 => list: ${list.length} ---- $index");
                var file = File(list[index]);

                if (context.mounted) context.showCustomDialog();
                String fileName = basename(file.path);
                console('Picked File Name: $fileName');

                // Get file extension
                String fileExtension = extension(file.path).replaceAll(".", "");
                console('Picked File Extension: $fileExtension');

                console('Picked File Extension: procedureId $procedureId');
                var type = "oem/${currentUser?.organizationName}/procedures/$procedureId/file";
                var result = await ProcedureViewModel().safeSignS3(fileName, "image/$fileExtension", true, type);
                // var result = await ProcedureViewModel()
                //     .safeSignS3(fileName, "image/$fileExtension", true, "");
                if (context.mounted) Navigator.pop(context);
                result.join(
                    (failed) => {console("failed => ${failed.exception}")},
                    (loaded) => {
                          observerUploadImageS3(loaded.data, file, fieldName,
                              fileExtension, index, list.length),

                        },
                    (loading) => {
                          console("loading => "),
                        });
              }
            }
          }

          Widget buildImageWrap(BuildContext context) {
            console(
                "buildImageWrap => ${formStateProvider.selectedImageList?.length}");

            return ChangeNotifierProvider.value(
              value: Provider.of<ProcedureProvider>(context, listen: true),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: formStateProvider.selectedImageList!
                    .map((String pickedImage) {
                  return Stack(
                    children: [
                      Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: FileImage(File(pickedImage)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            formStateProvider
                                .deleteImageFieldValue(pickedImage);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.grey, width: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset("assets/images/delete.svg"),
                          ),
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            );
          }

          return SingleChildScrollView(
            child: ChangeNotifierProvider.value(
              value: Provider.of<ProcedureProvider>(context, listen: true),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                width: context.fullWidth(),
                height: context.fullHeight(multiplier: 0.5),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                        text: "Upload Images",
                        textColor: textColorDark,
                        textFontWeight: FontWeight.bold,
                        fontSize: 18),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            pickImageFromGallery();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.grey, width: 0.1)),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  color: primaryColor,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextView(
                                    text: "Choose Photo",
                                    textColor: textColorLight,
                                    textFontWeight: FontWeight.normal,
                                    fontSize: 14)
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            takePhoto(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.grey, width: 0.1)),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  color: primaryColor,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextView(
                                    text: "Take Photo",
                                    textColor: textColorLight,
                                    textFontWeight: FontWeight.normal,
                                    fontSize: 14)
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(child: buildImageWrap(context)),
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
                                  title: "Cancel",
                                  onPressed: () {
                                    Navigator.pop(context);
                                  })),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                              child: CustomElevatedButton(
                                  backgroundColor: primaryColor,
                                  textColor: Colors.white,
                                  borderRadius: 8,
                                  title: "Upload Images",
                                  onPressed: () {
                                    uploadImagesToS3();
                                  })),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
