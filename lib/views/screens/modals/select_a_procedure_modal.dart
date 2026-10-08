import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/attach_procedure_to_work_order_response.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/context_function.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/procedure_viewmodel.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/procedure_provider.dart';
import 'package:makula_oem/views/widgets/custom_elevated_button.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';

class SelectProcedureModal {
  static void show(
      BuildContext context,
      GetProcedureTemplatesResponse? getProcedureTemplatesResponse,
      String workOrderId,
      VoidCallback callback) {
    showModalBottomSheet(
      context: context,
      barrierLabel: "Select a Procedure",
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        var procedureProvider =
            Provider.of<ProcedureProvider>(context, listen: true);

        observerAttachProcedureToWorkOrder(
            AttachProcedureToWorkOrderResponse response) {
          context.showSuccessSnackBar(
              response.attachOwnOemProcedureToWorkOrder ?? "");
        }

        attachProcedureToWorkOrder(
            String workOrderId, String templateId) async {
          var isConnected = await isConnectedToNetwork();
          if (isConnected) {
            if (context.mounted) {
              context.showCustomDialog();
            }
            var result = await ProcedureViewModel()
                .attachProcedureToWorkOrder(workOrderId, templateId);
            if (context.mounted) {
              Navigator.pop(context);
            }
            result.join(
                (failed) => {console("failed => ${failed.exception}")},
                (loaded) => {
                      Navigator.pop(context),
                      procedureProvider.updateSelectedProcedure(null),
                      observerAttachProcedureToWorkOrder(loaded.data),
                      callback()
                    },
                (loading) => {
                      console("loading => "),
                    });
          }
        }

        return ChangeNotifierProvider.value(
          value: Provider.of<ProcedureProvider>(context, listen: true),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: context.fullWidth(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const TextView(
                    text: "Select a procedure",
                    textColor: Colors.black,
                    textFontWeight: FontWeight.bold,
                    fontSize: 18),
                const SizedBox(
                  height: 20,
                ),
                const TextView(
                    text: "Select a procedure to use in this work order",
                    textColor: Colors.grey,
                    textFontWeight: FontWeight.normal,
                    fontSize: 12),
                const SizedBox(
                  height: 8,
                ),
                Expanded(
                    child: SelectProcedureExpansionTile(
                  templatesResponse: getProcedureTemplatesResponse,
                )),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: CustomElevatedButton(
                            backgroundColor: visitContainerColor,
                            textColor: primaryColor,
                            borderRadius: 8,
                            title: "Cancel",
                            onPressed: () {
                              Navigator.pop(context);
                              procedureProvider.updateSelectedProcedure(null);
                            })),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                        flex: 2,
                        child: CustomElevatedButton(
                            backgroundColor:
                                procedureProvider.selectedProcedure != null
                                    ? primaryColor
                                    : Colors.grey,
                            textColor: Colors.white,
                            borderRadius: 8,
                            isValid:
                                procedureProvider.selectedProcedure != null,
                            title: "Attach procedure",
                            onPressed: () {
                              if (procedureProvider.selectedProcedure != null) {
                                attachProcedureToWorkOrder(
                                    workOrderId,
                                    procedureProvider.selectedProcedure?.sId ??
                                        "");
                                //Navigator.pop(context);

                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //           ProcedureScreen(
                                //            templates: procedureProvider.selectedProcedure,
                                //           )),
                                //
                                // );
                              }
                            })),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class SelectProcedureExpansionTile extends StatelessWidget {
  final GetProcedureTemplatesResponse? templatesResponse;

  const SelectProcedureExpansionTile(
      {super.key, required this.templatesResponse});

  @override
  Widget build(BuildContext context) {
    var procedureProvider =
        Provider.of<ProcedureProvider>(context, listen: true);
    return ExpansionTile(
      collapsedBackgroundColor: Colors.grey.shade200,
      title: TextView(
          text: procedureProvider.selectedProcedure?.name ?? "Select",
          textColor: Colors.black,
          textFontWeight: FontWeight.normal,
          fontSize: 12),
      children: [
        SizedBox(
          height: context.fullHeight(multiplier: 0.24),
          child: ListView.builder(
            itemCount: templatesResponse?.listOwnOemProcedureTemplates?.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  console(
                      "templatesResponse => ${templatesResponse?.listOwnOemProcedureTemplates?[index].sId}");
                  procedureProvider.updateSelectedProcedure(
                      templatesResponse!.listOwnOemProcedureTemplates?[index]);

                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   controller.collapse(); // Collapse the ExpansionTile
                  // });
                  //Navigator.pop(context); // Close the Bottom Sheet
                },
                title: TextView(
                    text: templatesResponse!
                            .listOwnOemProcedureTemplates?[index].name ??
                        "",
                    textColor: Colors.black,
                    textFontWeight: FontWeight.normal,
                    fontSize: 12),
              );
            },
          ),
        )
      ],
    );
  }
}
