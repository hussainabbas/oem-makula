// import 'package:dropdown_search/dropdown_search.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:makula_oem/helper/model/create_template_response.dart';
import 'package:makula_oem/helper/model/get_machines_response.dart';
import 'package:makula_oem/helper/model/list_all_machines.dart';
import 'package:makula_oem/helper/model/list_customers.dart';
import 'package:makula_oem/helper/model/list_own_oem_customers_model.dart';
import 'package:makula_oem/helper/model/list_template_response.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/addNewTicket/provider/add_ticket_provider.dart';
import 'package:makula_oem/views/screens/dashboard/addNewTicket/viewmodel/add_ticket_view_model.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/documents/document_view_model.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/documents/document_viewer_screen.dart';
import 'package:makula_oem/views/widgets/makula_app_bar_gray.dart';
import 'package:makula_oem/views/widgets/makula_button.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';

class CreateDocumentScreen extends StatefulWidget {
  const CreateDocumentScreen({Key? key, required ListOwnOemTemplates template})
      : _template = template,
        super(key: key);

  final ListOwnOemTemplates _template;

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen> {
  AllOwnOemCustomersModel _customersModel = AllOwnOemCustomersModel();
  GetMachinesResponse _machinesResponse = GetMachinesResponse();
  late AddTicketProvider addTicketProvider;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    addTicketProvider = Provider.of<AddTicketProvider>(context, listen: false);
    addTicketProvider.clearDescValues();
    addTicketProvider.clearTitleValues();
    addTicketProvider.clearValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: _getListOwnOemCustomers(),
          builder: (context, projectSnap) {
            if (projectSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (projectSnap.hasError) {
              return const Center(child: Text(unexpectedError));
            } else {
              return Column(
                children: [
                  AppBarCustom(
                    title: widget._template.templateData?.name ?? "",
                  ),
                  Expanded(child: _body()),
                  SizedBox(
                    width: 200,
                    child: MyButton(
                        text: "Continue",
                        textColor: Colors.white,
                        textFontWeight: FontWeight.w700,
                        fontSize: 14,
                        buttonColor: primaryColor,
                        elevation: 10,
                        onPressed: () {
                          _createTemplate();
                        }),
                  ),
                  const SizedBox(
                    height: 24,
                  )
                ],
              );
            }
          }),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: ChangeNotifierProvider<AddTicketProvider>(
          create: (context) => AddTicketProvider(),
          child:
              Consumer<AddTicketProvider>(builder: (context, provider, child) {
            return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    SvgPicture.asset("assets/images/ic_docs.svg"),
                    const SizedBox(
                      height: 16,
                    ),
                    TextView(
                        text: "Use This Template to Create a New Document",
                        textColor: textColorDark,
                        textFontWeight: FontWeight.w700,
                        fontSize: 14),
                    const SizedBox(
                      height: 8,
                    ),
                    TextView(
                        text:
                            "Once you fill out the form you need to click Submit and document will be automatically generated.",
                        textColor: textColorLight,
                        textFontWeight: FontWeight.w400,
                        align: TextAlign.center,
                        fontSize: 14),
                    const SizedBox(
                      height: 24,
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: TextView(
                          text: "Facility Name",
                          textColor: textColorLight,
                          textFontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
                    const SizedBox(
                      height: 8,
                    ),

                    DropdownSearch<Customers>(
                      //mode: Mode.MENU,
                      //showSearchBox: true,
                      items: _customersModel.listAllOwnOemCustomers?.customers ?? [],
                      selectedItem: addTicketProvider.facilityData,
                      itemAsString: (Customers? u) =>
                      u == null ? "" : u.name.toString(),
                      onChanged: (Customers? data) => {
                        addTicketProvider.setFacilityData(data),
                        addTicketProvider.setMachineData(null),
                        provider.setReporterData(null),

                        addTicketProvider.getMachineListFromFacility(data?.machines),

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
                    // DropdownSearch<ListOwnOemCustomers>(
                    //   mode: Mode.MENU,
                    //   showSearchBox: true,
                    //   items: _customersModel.listOwnOemCustomers,
                    //   selectedItem: addTicketProvider.facilityData,
                    //   itemAsString: (ListOwnOemCustomers? u) =>
                    //       u == null ? "" : u.name.toString(),
                    //   onChanged: (ListOwnOemCustomers? data) => {
                    //     addTicketProvider.setFacilityData(data),
                    //     addTicketProvider.setMachineData(null),
                    //     provider.setReporterData(null),
                    //     //_listOwnOemFacilityUsers(data?.sId.toString() ?? ""),
                    //     addTicketProvider
                    //         .getMachineListFromFacility(data?.machines),
                    //   },
                    //   popupShape: RoundedRectangleBorder(
                    //     side: BorderSide(color: primaryColor, width: .5),
                    //     borderRadius: const BorderRadius.vertical(
                    //         bottom: Radius.circular(8)),
                    //   ),
                    //   searchFieldProps: TextFieldProps(
                    //     decoration: InputDecoration(
                    //       hintText: "Search Facility",
                    //       contentPadding:
                    //           const EdgeInsets.only(left: 8, bottom: 4),
                    //
                    //       //This is for Inner DropDown Search Input
                    //       enabledBorder: OutlineInputBorder(
                    //         borderSide:
                    //             BorderSide(color: textColorLight, width: .5),
                    //         borderRadius:
                    //             const BorderRadius.all(Radius.circular(8)),
                    //       ),
                    //     ),
                    //   ),
                    //   dropdownSearchDecoration: InputDecoration(
                    //     hintText: "Choose Facility",
                    //     contentPadding:
                    //         const EdgeInsets.only(left: 16, bottom: 8),
                    //     border: OutlineInputBorder(
                    //       borderSide: BorderSide(color: primaryColor, width: 2),
                    //       borderRadius:
                    //           const BorderRadius.all(Radius.circular(8)),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderSide:
                    //           BorderSide(color: primaryColor, width: .5),
                    //       borderRadius: const BorderRadius.vertical(
                    //           top: Radius.circular(8)),
                    //     ),
                    //   ),
                    // ),
                    addTicketProvider.facilityData == null
                        ? Container(
                            margin: const EdgeInsets.only(top: 4),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                SvgPicture.asset("assets/images/errors.svg"),
                                const SizedBox(
                                  width: 4,
                                ),
                                TextView(
                                    text: 'This field is required.',
                                    textColor: redStatusColor,
                                    textFontWeight: FontWeight.w600,
                                    fontSize: 12)
                              ],
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      height: 24,
                    ),
                    Container(
                        alignment: Alignment.topLeft,
                        child: TextView(
                            text: "Machine",
                            textColor: textColorLight,
                            textFontWeight: FontWeight.w500,
                            fontSize: 12)),
                    const SizedBox(
                      height: 6,
                    ),
                    DropdownSearch<ListMachines>(
                      //mode: Mode.MENU,
                      //showSearchBox: true,
                      items: addTicketProvider.machineList ?? [],
                      selectedItem: addTicketProvider.selectedMachineData,
                      itemAsString: (ListMachines? u) =>
                      u == null ? "" : u.name.toString(),
                      onChanged: (ListMachines? data) => {
                        addTicketProvider.setMachineData(data!),
                        provider.setReporterData(null),
                        provider.setReporterData(null),
                        // addTicketProvider.setFacilityData(Customers(
                        //   sId: data.customer?.sId.toString(),
                        //   name: data.customer?.name.toString(),
                        // )),
                        //_listOwnOemFacilityUsers(data.customer?.sId.toString() ?? ""),
                      },
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "Select Machine",
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
                    // DropdownSearch<ListMachines>(
                    //   mode: Mode.MENU,
                    //   showSearchBox: true,
                    //   selectedItem: addTicketProvider.selectedMachineData,
                    //   items: addTicketProvider.machineList,
                    //   itemAsString: (ListMachines? u) => u == null
                    //       ? ""
                    //       : "${u.name.toString()} • ${u.serialNumber.toString()}",
                    //   onChanged: (ListMachines? data) => {
                    //     addTicketProvider.setMachineData(data!),
                    //     provider.setReporterData(null),
                    //     addTicketProvider.setFacilityData(ListOwnOemCustomers(
                    //       sId: data.customers![0].sId.toString(),
                    //       name: data.customers![0].name.toString(),
                    //     )),
                    //     //_listOwnOemFacilityUsers(data.customers![0].sId.toString()),
                    //   },
                    //   popupShape: RoundedRectangleBorder(
                    //     side: BorderSide(color: primaryColor, width: .5),
                    //     borderRadius: const BorderRadius.vertical(
                    //         bottom: Radius.circular(8)),
                    //   ),
                    //   searchFieldProps: TextFieldProps(
                    //     decoration: InputDecoration(
                    //       hintText: "Search Machine",
                    //       contentPadding:
                    //           const EdgeInsets.only(left: 8, bottom: 4),
                    //
                    //       //This is for Inner DropDown Search Input
                    //       enabledBorder: OutlineInputBorder(
                    //         borderSide:
                    //             BorderSide(color: textColorLight, width: .5),
                    //         borderRadius:
                    //             const BorderRadius.all(Radius.circular(8)),
                    //       ),
                    //     ),
                    //   ),
                    //   dropdownSearchDecoration: InputDecoration(
                    //     hintText: "Choose Machine",
                    //     contentPadding:
                    //         const EdgeInsets.only(left: 16, bottom: 8),
                    //     border: OutlineInputBorder(
                    //       borderSide: BorderSide(color: primaryColor, width: 2),
                    //       borderRadius:
                    //           const BorderRadius.all(Radius.circular(8)),
                    //     ),
                    //     //This is for the main panel, when the dropdown appears.
                    //     focusedBorder: OutlineInputBorder(
                    //       borderSide:
                    //           BorderSide(color: primaryColor, width: .5),
                    //       borderRadius: const BorderRadius.vertical(
                    //           top: Radius.circular(8)),
                    //     ),
                    //   ),
                    // ),
                    addTicketProvider.selectedMachineData == null
                        ? Container(
                            margin: const EdgeInsets.only(top: 4),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                SvgPicture.asset("assets/images/errors.svg"),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'This field is required.',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12,
                                    color: redStatusColor,
                                    fontWeight: FontWeight.w600,
                                    height: 1.6666666666666667,
                                  ),
                                  textHeightBehavior: const TextHeightBehavior(
                                      applyHeightToFirstAscent: false),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      height: 24,
                    ),
                    Container(
                        alignment: Alignment.topLeft,
                        child: TextView(
                            text: "Inspection Date",
                            textColor: textColorLight,
                            textFontWeight: FontWeight.w500,
                            fontSize: 12)),
                    const SizedBox(
                      height: 6,
                    ),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(color: Colors.grey, spreadRadius: 1),
                          ],
                        ),
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextView(
                                    text:
                                        "${selectedDate.day.toString()}/${selectedDate.month.toString()}/${selectedDate.year.toString()}",
                                    textColor: textColorDark,
                                    textFontWeight: FontWeight.w400,
                                    fontSize: 16),
                                SvgPicture.asset("assets/images/btn_down.svg")
                              ],
                            )),
                      ),
                    ),
                    /* selectedDate == null
                        ? Container(
                            margin: const EdgeInsets.only(top: 4),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                SvgPicture.asset("assets/images/errors.svg"),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'This field is required.',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12,
                                    color: redStatusColor,
                                    fontWeight: FontWeight.w600,
                                    height: 1.6666666666666667,
                                  ),
                                  textHeightBehavior: const TextHeightBehavior(
                                      applyHeightToFirstAscent: false),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          )
                        : Container(),*/
                  ],
                ));
          })),
    );
  }

  _createTemplate() async {
    var provider = Provider.of<AddTicketProvider>(context, listen: false);
    String facilityId = provider.facilityData?.sId.toString() ?? "";
    String machineId = provider.selectedMachineData?.sId.toString() ?? "";
    String date =
        "${selectedDate.day.toString()}/${selectedDate.month.toString()}/${selectedDate.year.toString()}";
    String templateId = widget._template.sId.toString();

    if (machineId.isNotEmpty &&
        facilityId.isNotEmpty &&
        date.isNotEmpty &&
        templateId.isNotEmpty) {
      context.showCustomDialog();
      var result = await DocumentViewModel()
          .getFormUrlByTemplateId(templateId, facilityId, machineId, selectedDate);
      Navigator.pop(context);
      result.join(
          (failed) => {
                console("failed => " + failed.exception.toString()),
                context.showErrorSnackBar(failed.exception)
              },
          (loaded) => {_createTemplateResponse(loaded.data)},
          (loading) => {
                console("loading => "),
              });
    }
  }

  _createTemplateResponse(CreateTemplateResponse _response) {
    console(_response.getOwnOemFormUrlByTemplateId.toString());
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(
          webUrl: _response.getOwnOemFormUrlByTemplateId.toString(),
          templateName: widget._template.templateData?.name.toString() ?? "",
        ),
      ),
    );
  }

  _getListOwnOemCustomers() async {
    var result = await AddTicketViewModel().getListOwnOemCustomers();
    result.join(
        (failed) => {},
        (loaded) => {
              _customersModel = loaded.data,
            },
        (loading) => {
              console("loading => "),
            });

    await _getAllMachines();
  }

  _getAllMachines() async {
    var result = await AddTicketViewModel().getAllMachines();
    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {
              _machinesResponse = loaded.data,
              _setMachineListOnProvider(_machinesResponse),
            },
        (loading) => {
              console("loading => "),
            });
  }

/*  _listOwnOemFacilityUsers(String facilityId) async {
    context.showCustomDialog();
    var result = await AddTicketViewModel().listFacilityUsers(facilityId);
    Navigator.pop(context);
    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {},
        (loading) => {
              console("loading => "),
            });
  }*/

  _setMachineListOnProvider(GetMachinesResponse _machinesResponse) {
    Provider.of<AddTicketProvider>(context, listen: false)
        .getMachineListFromFacility(_machinesResponse.listOwnOemMachines);
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    );
    console(selected.toString());
    if (selected != null && selected != selectedDate) {
      selectedDate = selected;
      context.read<AddTicketProvider>().setSelectedDate(selectedDate);
    }
  }
}
