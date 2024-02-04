// import 'package:dropdown_search/dropdown_search.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/model/facility_users_model.dart';
import 'package:makula_oem/helper/model/get_machines_response.dart';
import 'package:makula_oem/helper/model/list_all_machines.dart';
import 'package:makula_oem/helper/model/list_customers.dart';
import 'package:makula_oem/helper/model/list_facility_users.dart';
import 'package:makula_oem/helper/model/list_own_oem_customers_model.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/context_function.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/modals/bottom_sheet_generic_modal.dart';
import 'package:makula_oem/views/screens/dashboard/addNewTicket/provider/add_ticket_provider.dart';
import 'package:makula_oem/views/screens/dashboard/addNewTicket/viewmodel/add_ticket_view_model.dart';
import 'package:makula_oem/views/widgets/makula_app_bar_gray.dart';
import 'package:makula_oem/views/widgets/makula_edit_text.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';

import '../../../../helper/model/get_inventory_part_list_response.dart';
import '../../../../helper/model/get_list_support_accounts_response.dart';
import '../tabbar/tickets/details/procedure_viewmodel.dart';

class CreateNewTicket extends StatefulWidget {
  const CreateNewTicket({super.key});

  @override
  State<CreateNewTicket> createState() => _CreateNewTicketState();
}

class _CreateNewTicketState extends State<CreateNewTicket> {
  AllOwnOemCustomersModel _customersModel = AllOwnOemCustomersModel();
  final GetMachinesResponse _machinesResponse = GetMachinesResponse();
  FacilityUsersModel _facilityUsersModel = FacilityUsersModel();
  late AddTicketProvider addTicketProvider;
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFieldFocus = FocusNode();
  final FocusNode _descFieldFocus = FocusNode();
  final TextEditingController _descriptionController = TextEditingController();

  _addEditTextListeners() {
    _titleController.addListener(() {
      if (_titleController.text.isNotEmpty) {
        addTicketProvider.setIsTitleValidate(true);
      } else {
        addTicketProvider.setIsTitleValidate(false);
      }
    });
  }

  @override
  void initState() {
    addTicketProvider = Provider.of<AddTicketProvider>(context, listen: false);
    addTicketProvider.clearDescValues();
    addTicketProvider.clearTitleValues();
    addTicketProvider.clearValues();
    _addEditTextListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus &&
                      currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                child: Column(
                  children: [
                    const AppBarCustom(
                      title: addNewTicketLabel,
                    ),
                    Expanded(child: _addTicketBody())
                  ],
                ),
              );
            }
          }),
    );
  }

  Widget _addTicketBody() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(padding: const EdgeInsets.all(16), child: _form())
                ],
              ),
            ),
          ),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                    // background
                    onPrimary: Colors.white,
                    // foreground
                    shadowColor: textColorLight,
                    elevation: 10,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  onPressed: () {
                    _submitTicket();
                  },
                  child: const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: TextView(
                          text: "Submit Work Order",
                          textColor: Colors.white,
                          textFontWeight: FontWeight.w700,
                          fontSize: 14)))),
        ],
      ),
    );
  }

  Widget _form() {
    return ChangeNotifierProvider<AddTicketProvider>(
        create: (context) => AddTicketProvider(),
        child: Consumer<AddTicketProvider>(builder: (context, provider, child) {
          return Column(
            children: [
              Container(
                  alignment: Alignment.topLeft,
                  child: TextView(
                      text: "Choose Work Order Type *",
                      textColor: textColorLight,
                      textFontWeight: FontWeight.w500,
                      fontSize: 12)),
              const SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  Radio(
                    activeColor: primaryColor,
                    value: 1,
                    groupValue: provider.selectionTicketTypeRadio,
                    onChanged: (value) {
                      provider.radioTicketTypeSelection(1);
                      addTicketProvider.setTicketType(ticketTypeServiceRequest);
                      console("RADIO BUTTON: ${addTicketProvider.ticketType}");
                    },
                  ),
                  const Text(ticketTypeServiceRequest2,
                      style: TextStyle(
                          fontFamily: "Manrope",
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  Radio(
                    activeColor: primaryColor,
                    value: 2,
                    groupValue: provider.selectionTicketTypeRadio,
                    onChanged: (value) {
                      provider.radioTicketTypeSelection(2);
                      addTicketProvider.setTicketType(ticketTypeSparePart2);
                      console("RADIO BUTTON: ${addTicketProvider.ticketType}");
                    },
                  ),
                  const Text(ticketTypeSparePart,
                      style: TextStyle(
                          fontFamily: "Manrope",
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                alignment: Alignment.topLeft,
                child: TextView(
                    text: "Select Facility *",
                    textColor: textColorLight,
                    textFontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              const SizedBox(
                height: 8,
              ),
              // Container(
              //   width: context.fullWidth(),
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(width: 1, color: Colors.grey)),
              //   child: GestureDetector(
              //       onTap: () {
              //         FocusScope.of(context).unfocus();
              //         BottomSheetGenericModal.show<Customers>(context, "Select Facility", _customersModel.listAllOwnOemCustomers?.customers, null, (p0) => p0?.name ?? "", (data) {
              //               addTicketProvider.setFacilityData(data);
              //               addTicketProvider.setMachineData(null);
              //               provider.setReporterData(null);
              //               _facilityUsersModel = GetListSupportAccountsResponse();
              //               _listOwnOemFacilityUsers(data?.sId.toString() ?? "");
              //               addTicketProvider.getMachineListFromFacility(data?.machines);
              //         });
              //       },
              //       child: TextView(
              //           text: addTicketProvider.facilityData != null ?  addTicketProvider.facilityData?.name ?? "" : "Select Facility",
              //           textColor: Colors.grey,
              //           textFontWeight: FontWeight.normal,
              //           fontSize: 14)),
              // ),

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
                  _facilityUsersModel = FacilityUsersModel(),
                  _listOwnOemFacilityUsers(data?.sId.toString() ?? ""),
                  addTicketProvider.getMachineListFromFacility(data?.machines),
                },
                popupProps: PopupProps.modalBottomSheet(
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
              addTicketProvider.facilityData == null ||
                      provider.facilityData == ListOwnOemCustomers()
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
                      text: "Select Machine *",
                      textColor: textColorLight,
                      textFontWeight: FontWeight.w500,
                      fontSize: 12)),
              const SizedBox(
                height: 6,
              ),

              // Container(
              //   width: context.fullWidth(),
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(width: 1, color: Colors.grey)),
              //   child: GestureDetector(
              //       onTap: () {
              //         FocusScope.of(context).unfocus();
              //         BottomSheetGenericModal.show(context, "Select Machine", addTicketProvider.machineList, null, (p0) => p0?.name ?? "", (data) {
              //                   addTicketProvider.setMachineData(data!);
              //                   provider.setReporterData(null);
              //                   // addTicketProvider.setFacilityData(Customers(
              //                   //   sId: data.customer?.sId.toString();
              //                   //   name: data.customer?.name.toString();
              //                   // ));
              //                   _listOwnOemFacilityUsers(data.customer?.sId.toString() ?? "");
              //         });
              //       },
              //       child: TextView(
              //           text: addTicketProvider.selectedMachineData != null ?  addTicketProvider.selectedMachineData?.name ?? "" : "Select Machine",
              //           textColor: Colors.grey,
              //           textFontWeight: FontWeight.normal,
              //           fontSize: 14)),
              // ),

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
                      _listOwnOemFacilityUsers(data.customer?.sId.toString() ?? ""),
                },
                popupProps: PopupProps.modalBottomSheet(
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
                      text: "Select Reporter",
                      textColor: textColorLight,
                      textFontWeight: FontWeight.w500,
                      fontSize: 12)),
              const SizedBox(
                height: 6,
              ),
              // Container(
              //   width: context.fullWidth(),
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(width: 1, color: Colors.grey)),
              //   child: GestureDetector(
              //       onTap: () {
              //         FocusScope.of(context).unfocus();
              //         BottomSheetGenericModal.show(context, "Select Reporter", _facilityUsersModel.listOwnOemSupportAccounts , null, (p0) => p0?.name ?? "", (data) {
              //           addTicketProvider.setReporterData(data);
              //         });
              //       },
              //       child: TextView(
              //           text: addTicketProvider.reporterData != null ?  addTicketProvider.reporterData?.name ?? "" : "Select Reporter",
              //           textColor: Colors.grey,
              //           textFontWeight: FontWeight.normal,
              //           fontSize: 14)),
              // ),
              DropdownSearch<ListOwnOemFacilityUsers>(
                //mode: Mode.MENU,
                //showSearchBox: true,
                items: _facilityUsersModel.listOwnOemFacilityUsers ?? [],
                selectedItem: addTicketProvider.reporterData,
                itemAsString: (ListOwnOemFacilityUsers? u) =>
                u == null ? "" : u.name.toString(),
                  onChanged: (ListOwnOemFacilityUsers? data) =>
                      {addTicketProvider.setReporterData(data)},
                popupProps: PopupProps.modalBottomSheet(
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
                    hintText: "Select Reporter",
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
                height: 24,
              ),
              _editTextBoxes()
            ],
          );
        }));
  }

  Widget _editTextBoxes() {
    return ChangeNotifierProvider<AddTicketProvider>(
        create: (context) => AddTicketProvider(),
        child: Consumer<AddTicketProvider>(builder: (context, provider, child) {
          return Column(
            children: [
              Container(
                  alignment: Alignment.topLeft,
                  child: TextView(
                      text: "Work Order Title *",
                      textColor: textColorLight,
                      textFontWeight: FontWeight.w500,
                      fontSize: 12)),
              const SizedBox(
                height: 6,
              ),
              EditText(
                  hintText: addTitleLabel,
                  textColor: textColorLight,
                  containerColor: addTicketProvider.isTitleFocused
                      ? Colors.white
                      : containerColorUnFocused,
                  textFontWeight: FontWeight.w500,
                  fontSize: 14,
                  controller: _titleController,
                  focusNode: _titleFieldFocus,
                  isValidate: false,
                  validateError: "This field is required"),
              _titleController.text.isEmpty
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
                      text: "Work Order Description",
                      textColor: textColorLight,
                      textFontWeight: FontWeight.w500,
                      fontSize: 12)),
              const SizedBox(
                height: 6,
              ),
              EditText(
                  hintText: addDescriptionLabel,
                  textColor: textColorLight,
                  containerColor: addTicketProvider.isDescriptionFocused
                      ? Colors.white
                      : containerColorUnFocused,
                  textFontWeight: FontWeight.w500,
                  fontSize: 14,
                  controller: _descriptionController,
                  focusNode: _descFieldFocus,
                  isValidate: false,
                  isBigEditText: true,
                  validateError: ""),
            ],
          );
        }));
  }

  _getListOwnOemCustomers() async {
    var result = await AddTicketViewModel().getListOwnOemCustomers();
    result.join(
        (failed) => {console("failed => ${failed.exception}")},
        (loaded) => {
              _customersModel = loaded.data,
            },
        (loading) => {
              console("loading => "),
            });

    //await _getAllMachines();
  }

  // _getAllMachines() async {
  //   var result = await AddTicketViewModel().getAllMachines();
  //   result.join(
  //       (failed) => {console("failed => ${failed.exception}")},
  //       (loaded) => {
  //             _machinesResponse = loaded.data,
  //             _setMachineListOnProvider(_machinesResponse),
  //           },
  //       (loading) => {
  //             console("loading => "),
  //           });
  // }

  _setMachineListOnProvider(GetMachinesResponse _machinesResponse) {
    Provider.of<AddTicketProvider>(context, listen: false)
        .getMachineListFromFacility(_machinesResponse.listOwnOemMachines);
  }

  _listOwnOemFacilityUsers(String facilityId) async {
    console("facilityId=> $facilityId");
    context.showCustomDialog();

    var result = await AddTicketViewModel().listFacilityUsers(facilityId);
    Navigator.pop(context);
    result.join(
            (failed) => {console("failed => ${failed.exception}")},
            (loaded) => {
              _facilityUsersModel = loaded.data,
              _setReporterListOnProvider(loaded.data),
        },
            (loading) => {
          console("loading => "),
        });
  }

  // _listOwnOemFacilityUsers(String facilityId) async {
  //   console("facilityId=> $facilityId");
  //   context.showCustomDialog();
  //
  //   var result = await ProcedureViewModel().getListSupportAccounts();
  //   Navigator.pop(context);
  //   result.join(
  //           (failed) => {console("failed => ${failed.exception}")},
  //           (loaded) => {
  //             _facilityUsersModel = loaded.data,
  //             _setReporterListOnProvider(loaded.data),
  //       },
  //           (loading) => {
  //         console("loading => "),
  //       });
  // }

  _setReporterListOnProvider(GetListSupportAccountsResponse response) {
    Provider.of<AddTicketProvider>(context, listen: false)
        .setReporterListFromFacility(response.listOwnOemSupportAccounts);
  }

  _submitTicket() async {
    var title = _titleController.text.toString();
    var description = _descriptionController.text.toString();

    if (title.isEmpty) {
      addTicketProvider.setIsTitleValidate(true);
    } else {
      addTicketProvider.setIsTitleValidate(false);
    }
    console(
        " addTicketProvider.isTitleValidated => ${addTicketProvider.isTitleValidated}");
    console("_submitTicket ${addTicketProvider.ticketType}");
    if (addTicketProvider.facilityData != null &&
        addTicketProvider.selectedMachineData != null &&
        title.isNotEmpty) {
      context.showCustomDialog();
      var result = await AddTicketViewModel().addNewTicket(
        addTicketProvider.selectedMachineData?.sId.toString() ?? "",
        title,
        description,
        addTicketProvider.ticketType,
        addTicketProvider.reporterData?.sId.toString() ?? "",
        addTicketProvider.facilityData?.sId.toString() ?? "",
      );
      Navigator.of(context).pop();
      result.join(
          (failed) => {console("failed => ${failed.exception}")},
          (loaded) => {
                Navigator.pop(context),
                context.showSuccessSnackBar("Work order created successfully"),
              },
          (loading) => {
                console("loading => "),
              });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
