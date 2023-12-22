import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/views/widgets/custom_elevated_button.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:signature/signature.dart';

class SignatureProcedureScreen extends StatefulWidget {
  const SignatureProcedureScreen({super.key});

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
      exportBackgroundColor: Colors.blue,

    );
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
                            onPressed: () {
                              controller.toImage();
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
