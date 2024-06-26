// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:makula_oem/helper/model/chat_message_model.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/get_own_oem_ticket_by_id_response.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';
import 'package:makula_oem/helper/model/get_ticket_detail_response.dart';
import 'package:makula_oem/helper/model/list_assignee_response.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/context_function.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/tickets_view_model.dart';
import 'package:makula_oem/main.dart';
import 'package:makula_oem/pubnub/message_provider.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/modals/bottom_sheet_generic_modal.dart';
import 'package:makula_oem/views/screens/dashboard/addNewTicket/viewmodel/add_ticket_view_model.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/procedure_screen_with_hooks.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/procedure_viewmodel.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/procedure_provider.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/ticket_provider.dart';
import 'package:makula_oem/views/screens/modals/select_a_procedure_modal.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

class TicketOverviewScreen extends StatefulWidget {
  const TicketOverviewScreen(
      {super.key, required String channelId, required OpenTicket ticket})
      : _ticket = ticket;

  final OpenTicket _ticket;

  @override
  _TicketOverviewScreenState createState() => _TicketOverviewScreenState();
}

class _TicketOverviewScreenState extends State<TicketOverviewScreen> {
  //OpenTicket _ticket = OpenTicket();
  GetOwnOemTicketById _ticketDetailData = GetOwnOemTicketById();
  CurrentUser _currentUser = CurrentUser();
  GetProcedureTemplatesResponse? _getProcedureTemplatesResponse =
      GetProcedureTemplatesResponse();

  // final appPreferences = AppPreferences();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _sendFieldFocus = FocusNode();
  late TicketProvider _ticketProvider;
  PubnubInstance? _pubnubInstance;
  MessageProvider? messageProvider;
  ListAssignee responseAssignee = ListAssignee();
  var _status = "";

  bool isConnected = false;
  List<StatusData>? oemStatus = [];

  //late TicketProvider _tickerProvider;

  _getOEMStatuesValueFromSP() async {
    isConnected = await isConnectedToNetwork();
    oemStatus =
        await appDatabase?.oemStatusDao.findAllGetOemStatusesResponses();
  }

  @override
  void initState() {
    _ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    _getValuesFromSP();
    _getOEMStatuesValueFromSP();

    console("_ticket => ${widget._ticket.sId}");
    //_addTextListeners();
    super.initState();
  }

  void _getValuesFromSP() async {
    _currentUser = (await appDatabase?.userDao.getCurrentUserDetailsFromDb())!;

    if (context.mounted) {
      _pubnubInstance = PubnubInstance(context);
      _pubnubInstance
          ?.setSubscriptionChannel(_currentUser.notificationChannel ?? "");
      messageProvider = MessageProvider(
          _pubnubInstance!, _currentUser.notificationChannel ?? "");


      // _pubnubInstance = PubnubInstance(context);
      _pubnubInstance?.setSubscriptionChannel(
          widget._ticket.ticketInternalNotesChatChannels?[0] ?? "");
      messageProvider = MessageProvider(_pubnubInstance!,
          widget._ticket.ticketInternalNotesChatChannels?[0] ?? "");

      messageProvider = MessageProvider(_pubnubInstance!,
          widget._ticket.ticketInternalNotesChatChannels?[0] ?? "");

    }


    // _currentUser = HiveResources.currentUserBox!
    //     .get(OfflineResources.CURRENT_USER_RESPONSE)!;
    _getTicketDetailResponse();
    console("_ticket => ${widget._ticket?.sId}");
  }

  @override
  Widget build(BuildContext context) {
    //_ticket = context.watch<TicketProvider>().ticketItem;


    return FutureBuilder(
        future: _getTicketDetailResponse(),
        builder: (context, projectSnap) {
          if (projectSnap.hasError) {
            return const Center(child: Text(unexpectedError));
          } else {
            return _ticketDetailData.sId != null
                ? _ticketOverviewContent()
                : Container();
          }
        });
  }

  _getTicketDetailResponse() async {
    var isConnected = await isConnectedToNetwork();
    if (isConnected) {
      var result =
          await TicketViewModel().getTicketById(widget._ticket.sId.toString());
      result.join(
          (failed) => {console("failed => ${failed.exception}")},
          (loaded) => {
                _getStatus(loaded.data),
                //     _ticketDetailData = loaded.data,
                // _getStatus(_ticketDetailData.getOwnOemTicketById?.status.toString() ?? "")
              },
          (loading) => {
                console("loading => "),
              });

      await getListOwnOemSupportAccounts();
    } else {
      _ticketDetailData = (await appDatabase?.getTicketDetailResponseDao
          .getTicketDetailResponseById(widget._ticket.sId ?? ""))!;
      console(
          "_ticketDetailData procedures => ${_ticketDetailData.procedures?.length}");
      responseAssignee = (await appDatabase?.getListAssignee.findAssignee())!;
      _getStatusFromDb();
      // responseAssignee = HiveResources.listAssigneeBox!.get(OfflineResources.LIST_ASSIGNEE_RESPONSE)!;
    }
  }

  _getStatusFromDb() async {
    var statusData =
        await getStatusById(_ticketDetailData.status.toString() ?? "");
    _status = statusData?.label ?? "";
  }

  _getStatus(GetTicketDetailResponse response) async {
    var statusData = await getStatusById(
        response.getOwnOemTicketById?.status.toString() ?? "");
    _status = statusData?.label ?? "";
    _ticketDetailData = response.getOwnOemTicketById!;

    await appDatabase?.getTicketDetailResponseDao
        .insertOrUpdateTicketDetailResponse(response.getOwnOemTicketById!);
  }

  getListOwnOemSupportAccounts() async {
    var isConnected = await isConnectedToNetwork();
    if (isConnected) {
      var result = await AddTicketViewModel().getListOwnOemSupportAccounts();
      result.join(
          (failed) => {console("failed => ${failed.exception}")},
          (loaded) => {
                //responseAssignee = loaded.data,
                _getListAssignee(loaded.data),
                // HiveResources.listAssigneeBox?.put(OfflineResources.LIST_ASSIGNEE_RESPONSE, loaded.data),

                // console("getListOwnOemSupportAccounts => ${HiveResources.listAssigneeBox!.get(OfflineResources.LIST_ASSIGNEE_RESPONSE)!.listOwnOemSupportAccounts?.length}")
              },
          (loading) => {
                console("loading => "),
              });
    } else {
      responseAssignee = (await appDatabase?.getListAssignee.findAssignee())!;
    }
  }

  _getListAssignee(ListAssignee listAssignee) async {
    responseAssignee = listAssignee;
    await appDatabase?.getListAssignee.insertListAssignee(listAssignee);

    await getProcedureTemplates();
  }

  getProcedureTemplates() async {
    var isConnected = await isConnectedToNetwork();
    if (isConnected) {
      var result = await ProcedureViewModel().getListProcedureTemplates();
      result.join(
          (failed) => {console("failed => ${failed.exception}")},
          (loaded) => {
                _observerGetProcedureTemplatesResponse(loaded.data),
              },
          (loading) => {
                console("loading => "),
              });
    } else {
      _getProcedureTemplatesResponse =
          (await appDatabase?.procedureTemplates.getProcedureTemplates())!;
      console(
          "_getProcedureTemplatesResponse => ${_getProcedureTemplatesResponse?.listOwnOemProcedureTemplates?.length}");
    }
  }

  _observerGetProcedureTemplatesResponse(
      GetProcedureTemplatesResponse response) async {
    _getProcedureTemplatesResponse = response;

    await appDatabase?.procedureTemplates.insertOrUpdate(response);
  }

  observerDetachProcedure() {
    setState(() {});
  }

  detachProcedure(String workOrderId, String procedureId) async {
    var isConnected = await isConnectedToNetwork();
    if (isConnected) {
      if (context.mounted) {
        context.showCustomDialog();
      }
      var result =
          await ProcedureViewModel().detachProcedure(workOrderId, procedureId);
      if (context.mounted) {
        Navigator.pop(context);
      }
      result.join(
          (failed) => {console("failed => ${failed.exception}")},
          (loaded) => {
                observerDetachProcedure(),
              },
          (loading) => {
                console("loading => "),
              });
    }
  }

  // _getProcedureById(String procedureId) async {
  //   var isConnected = await isConnectedToNetwork();
  //   if (context.mounted) context.showCustomDialog();
  //   if (isConnected) {
  //     var result = await ProcedureViewModel().getProcedureById(procedureId);
  //     if (context.mounted) Navigator.pop(context);
  //     result.join(
  //             (failed) => {console("failed => ${failed.exception}")},
  //             (loaded) => {
  //              console("_getProcedureById -> Response => ${loaded.data}"), _observerGetProcedureByIdResponse(loaded.data),
  //         },
  //             (loading) => {
  //           console("loading => "),
  //         });
  //   }
  // }
  //
  // _observerGetProcedureByIdResponse(GetProcedureByIdResponse response) {
  //   ListOwnOemProcedureTemplates? templates = response.getOwnOemProcedureById;
  //   console("_observerGetProcedureByIdResponse => ${response.getOwnOemProcedureById?.state}");
  //   console("_observerGetProcedureByIdResponse => ${response.getOwnOemProcedureById?.pdfUrl}");
  //
  //   // Navigator.of(context).push(
  //   //   MaterialPageRoute(
  //   //       builder: (context) =>
  //   //           ProcedureScreen(
  //   //             templates: templates,
  //   //             state: response.getOwnOemProcedureById?.state,
  //   //             pdfUrl: response.getOwnOemProcedureById?.pdfUrl,
  //   //             workOrderId: _ticketDetailData.sId,
  //   //           )),
  //   //
  //   // );
  // }

  Widget _ticketOverviewContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      TextView(
                          text:
                              "${_ticketDetailData.title?.capitalizeString()}",
                          textColor: textColorDark,
                          textFontWeight: FontWeight.w600,
                          fontSize: 17),
                      const SizedBox(
                        height: 8,
                      ),
                      TextView(
                          text:
                              "${_ticketDetailData.machine?.name?.capitalizeString()} "
                              " •  ${_ticketDetailData.machine?.serialNumber.toString()}",
                          textColor: textColorLight,
                          textFontWeight: FontWeight.w500,
                          fontSize: 12),
                      const SizedBox(
                        height: 24,
                      ),
                      _detailInTable(),
                      const SizedBox(
                        height: 28,
                      ),

                      Container(
                        width: context.fullWidth(),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 0.1)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextView(
                                text: "Work Order Description",
                                textColor: Colors.black,
                                textFontWeight: FontWeight.bold,
                                fontSize: 14),
                            const SizedBox(
                              height: 8,
                            ),
                            Html(
                              data: generateHtmlString(
                                  _ticketDetailData.description ?? ""),
                              // You can customize styling using various parameters in FlutterHtml
                            ),
                          ],
                        ),
                      ),

                      // ReadMoreText(
                      //   _ticketDetailData.description.toString() ?? "",
                      //   colorClickableText: primaryColor,
                      //   trimCollapsedText: '...Read more',
                      //   trimExpandedText: ' Read less',
                      //   style: const TextStyle(
                      //       fontFamily: 'Manrope',
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w500),
                      // ),

                      const SizedBox(
                        height: 16,
                      ),

                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 0.5, color: Colors.grey)),
                        child: ExpansionTile(
                          shape: Border.all(width: 0),
                          title: Row(
                            children: [
                              SvgPicture.asset(
                                  "assets/images/ic_procedures.svg"),
                              const SizedBox(
                                width: 10,
                              ),
                              const Expanded(
                                  child: TextView(
                                      text: "Procedures",
                                      textColor: Colors.black,
                                      textFontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ],
                          ),
                          children: [
                            if (_ticketDetailData.procedures?.isNotEmpty ==
                                true)
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _ticketDetailData.procedures?.length,
                                itemBuilder: (context, index) {
                                  var item =
                                      _ticketDetailData.procedures?[index];
                                  console(
                                      "procedures => ${item?.procedure?.sId}");
                                  return ListTile(
                                    onTap: () async {
                                      Provider.of<ProcedureProvider>(context,
                                          listen: false)
                                          .clearFieldValues();
                                      //_getProcedureById(item?.procedure?.sId ?? "");
                                      final result =
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProcedureScreenWithHooks(
                                                  pubnubInstance:
                                                  _pubnubInstance,
                                                  messageProvider:
                                                  messageProvider,
                                                  templatesId:
                                                  item?.procedure?.sId ??
                                                      "",
                                                  ticketName:
                                                  widget._ticket.title ??
                                                      "",
                                                )),
                                      );

                                      console(
                                          "TICKET-OVERVIEW -> REFRESH1: $result");
                                      if (result == 'refresh') {
                                        console("TICKET-OVERVIEW -> REFRESH");
                                        setState(() {});
                                      }
                                    },
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: TextView(
                                              text: item?.procedure?.name ?? "",
                                              textColor: textColorLight,
                                              textFontWeight: FontWeight.normal,
                                              fontSize: 12),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                color: item?.procedure?.state !=
                                                        "FINALIZED"
                                                    ? lightGray
                                                    : closedContainerColor,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.fromLTRB(8,
                                                4, 4, 5),
                                            child: TextView(
                                                align: TextAlign.center,
                                                text: item?.procedure?.state
                                                        ?.replaceAll(
                                                            "_", " ") ??
                                                    "",
                                                textColor:
                                                    item?.procedure?.state !=
                                                            "FINALIZED"
                                                        ? textColorLight
                                                        : closedStatusColor,
                                                textFontWeight:
                                                    FontWeight.normal,
                                                fontSize: 12)),
                                      ],
                                    ),
                                    trailing: IgnorePointer(
                                      ignoring: _status == "Closed",
                                      child: PopupMenuButton<String>(
                                          color: Colors.white,
                                          onSelected: (value) async {
                                            if (value == "open") {
                                              Provider.of<ProcedureProvider>(
                                                      context,
                                                      listen: false)
                                                  .clearFieldValues();
                                              //_getProcedureById(item?.procedure?.sId ?? "");
                                              final result =
                                                  await Navigator.of(context)
                                                      .push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProcedureScreenWithHooks(
                                                          pubnubInstance:
                                                              _pubnubInstance,
                                                          messageProvider:
                                                              messageProvider,
                                                          templatesId: item
                                                                  ?.procedure
                                                                  ?.sId ??
                                                              "",
                                                          ticketName: widget
                                                                  ._ticket
                                                                  .title ??
                                                              "",
                                                        )),
                                              );
                                              console(
                                                  "TICKET-OVERVIEW -> REFRESH1: $result");
                                              if (result == 'refresh') {
                                                console(
                                                    "TICKET-OVERVIEW -> REFRESH");
                                                setState(() {});
                                              }
                                              // Navigator.of(context).push(
                                              //   MaterialPageRoute(
                                              //       builder: (context) =>
                                              //           ProcedureScreenWithHooks(
                                              //             pubnubInstance:
                                              //                 _pubnubInstance,
                                              //             messageProvider:
                                              //                 messageProvider,
                                              //             templatesId: item
                                              //                     ?.procedure
                                              //                     ?.sId ??
                                              //                 "",
                                              //             ticketName: widget
                                              //                     ._ticket
                                              //                     .title ??
                                              //                 "",
                                              //           )),
                                              // );
                                            } else {
                                              detachProcedure(
                                                  widget._ticket.sId ?? "",
                                                  item?.procedure?.sId ?? "");
                                              console(
                                                  "PopupMenuButton => ${widget._ticket.sId} ---- ${item?.procedure?.sId}");
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return [
                                              const PopupMenuItem<String>(
                                                value: 'open',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit_outlined),
                                                    SizedBox(width: 8),
                                                    Text('Open'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'delete',
                                                enabled:
                                                    item?.procedure?.state !=
                                                        "FINALIZED",
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.delete),
                                                    SizedBox(width: 8),
                                                    Text('Delete'),
                                                  ],
                                                ),
                                              ),
                                            ];
                                          },
                                          child: const Icon(Icons.more_horiz)),
                                    ),

                                    // const Icon(Icons.more_horiz),
                                  );
                                },
                              ),
                            GestureDetector(
                              onTap: () {
                                if (_status.toLowerCase() != "closed") {
                                  SelectProcedureModal.show(
                                      context,
                                      _getProcedureTemplatesResponse,
                                      widget._ticket.sId ?? "", () {
                                    console("Callback");
                                    setState(() {});
                                  });
                                }
                                //Navigator.pushNamed(context, procedureScreenRoute);
                              },
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, left: 16),
                                  alignment: Alignment.centerLeft,
                                  width: context.fullWidth(),
                                  child: TextView(
                                      text: "+ Add Procedure instance",
                                      textColor:
                                          _status.toLowerCase() != "closed"
                                              ? primaryColor
                                              : Colors.grey,
                                      textFontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                      )

                      // const SizedBox(
                      //   height: 28,
                      // ),
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.pushNamed(context, procedureScreenRoute);
                      //   },
                      //   child: Text("Procedures"),
                      // ),
                    ],
                  ),
                ),
                //_ticketDetailWidgets(response),
                if (isConnected)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: _internalNotesFormPN(),
                  ),
              ],
            ),
          ),
        ),
        Opacity(
          opacity: 0.3,
          child: line(context),
        ),

        _status.toLowerCase() != "closed" && isConnected
            ? InternalNotesWidget(
                messageController: _messageController,
                sendFieldFocus: _sendFieldFocus,
                currentUser: _currentUser,
                sendInternalNotes: _sendInternalNotes)
            : Container()
        //_internalNotesFormPN()
      ],
    );
  }

  void _sendInternalNotes() async {
    var isConnected = await isConnectedToNetwork();
    if (isConnected) {
      if (_messageController.text.isNotEmpty) {
        if (context.mounted) {
          context.showCustomDialog();
        }
        await messageProvider!.sendMessage(
            widget._ticket.ticketInternalNotesChatChannels![0],
            _messageController.text);
        _messageController.text = "";
        if (context.mounted) {
          Navigator.pop(context);
          context.showSuccessSnackBar("Internal Note Saved");
        }
      }
    }
  }

  Widget _internalNotesFormPN() {
    return ChangeNotifierProvider<MessageProvider>(
      create: (context) => messageProvider!,
      child: Consumer<MessageProvider>(builder: (context, value, child) {
        messageProvider?.addListener(() {
          console("messageProvider?.addListene");
        });
        return _internalNotesListView(value.messages);
      }),
    );
  }

  Widget _internalNotesListView(List<ChatMessage> _messageList) {

    List<ChatMessage> list = [];
    _messageList.reversed?.forEach((element) {
      console("message -> ${element.message["text"]} ---- ${messageProvider?.attachProcedureLoading}");
      if (element.message["text"] != "attachOwnOemProcedureToWorkOrder" && element.message["text"] != "finalizeOwnOemProcedure" && element.message["text"] != "downloadProcedurePDF" && element.message["text"] != "saveOwnOemProcedureTemplate" ) {
        list.add(element);
      }
    });


    Future.delayed(const Duration(milliseconds: 100), (){
      setState(() {
        console("_ticket => messageProvider?.attachProcedureLoading - ${messageProvider?.attachProcedureLoading}");
      });
    });

    return _messageList.isNotEmpty ? _internalNotesWidget(list) : _noNotes();
  }

  Widget _noNotes() {
    return messageProvider!.isChatLoading
        ? const Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : Row(
            children: [
              SvgPicture.asset("assets/images/No Internal Notes.svg"),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  "There Are No Internal Notes Added For This Ticket.",
                  style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColorLight),
                ),
              )
            ],
          );
  }

  Widget _internalNotesWidget(List<ChatMessage> _messageList) {
    //print"_internalNotesWidget");
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 12),
      width: MediaQuery.of(context).size.width,
      child: FixedTimeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          color: const Color(0xff989898),
          indicatorTheme: const IndicatorThemeData(
            position: 0,
            size: 20.0,
          ),
          connectorTheme: const ConnectorThemeData(
            thickness: 2.5,
          ),
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          indicatorBuilder: (_, index) => OutlinedDotIndicator(
            borderWidth: 6.0,
            color: primaryColor,
          ),
          connectorBuilder: (_, index, ___) => SolidLineConnector(
            color: borderColor,
            thickness: 2.0,
          ),
          contentsBuilder: (context, index) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parseHtmlString(_messageList[index].message['text'])
                      .toString(),
                  style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 4,
                ),
                RichText(
                    text: TextSpan(
                        style: TextStyle(color: textColorLight),
                        children: [
                      TextSpan(
                        text: _messageList[index].userName.isNotEmpty
                            ? _messageList[index].userName
                            : _currentUser.name.toString(),
                        style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text:
                            ", ${getFormattedDate(_messageList[index].timeToken, formatDateEEEMMMDDHHMMA)}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ])),
              ],
            ),
          ),
          itemCount: _messageList.length,
        ),
      ),
    );
  }

  Widget _detailInTable() {
    return Table(
      defaultColumnWidth: const FixedColumnWidth(150),
      children: [
        TableRow(children: [
          TextView(
            text: dateLabel.toUpperCase(),
            fontSize: 13,
            textFontWeight: FontWeight.w700,
            textColor: textColorLight,
          ),
          TextView(
            text: _ticketDetailData.createdAt?.formatDate(
                    dateFormatYYYMMddTHHmmssSSSZ, dateFormatYYYYddMM) ??
                "",
            fontSize: 13,
            textFontWeight: FontWeight.w500,
            textColor: textColorDark,
          ),
        ]),
        const TableRow(children: [
          SizedBox(
            height: 18,
          ),
          SizedBox(
            height: 18,
          ),
        ]),
        TableRow(children: [
          TextView(
            text: ticketIdLabel.toUpperCase(),
            fontSize: 13,
            textFontWeight: FontWeight.w700,
            textColor: textColorLight,
          ),
          TextView(
            text: ticketID(_ticketDetailData.ticketId.toString() ?? ""),
            fontSize: 13,
            textFontWeight: FontWeight.w500,
            textColor: textColorDark,
          )
        ]),
        const TableRow(children: [
          SizedBox(
            height: 18,
          ),
          SizedBox(
            height: 18,
          ),
        ]),
        TableRow(children: [
          TextView(
            text: "Status:",
            fontSize: 13,
            textFontWeight: FontWeight.w700,
            textColor: textColorLight,
          ),
          GestureDetector(
            onTap: () async {
              if (_status.toLowerCase() != "closed") {
                _closeSnackBars();
                var oemStatus = await appDatabase?.oemStatusDao
                    .findAllGetOemStatusesResponses();

                BottomSheetGenericModal.show(
                    context,
                    "Select Status",
                    oemStatus?[oemStatus.length - 1]
                        .listOwnOemOpenTickets?[0]
                        .oem
                        ?.statuses,
                    null,
                    (p0) => p0?.label ?? "", (p0) {
                  _ticketProvider.setTicketStatus(p0?.label ?? "");
                  _getStatusByName(p0?.sId ?? "");
                });
                //_showStatusModal(context, _ticketDetailData);
              }
            },
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                        color: hexStringToColor2F(getStatusColorById(
                            _ticketDetailData.status ?? "", oemStatus))),
                    child: Text(
                      _status.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Manrope',
                          color: hexStringToColor(getStatusColorById(
                              _ticketDetailData.status ?? "", oemStatus)),
                          fontSize: 14),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ]),
        const TableRow(children: [
          SizedBox(
            height: 14,
          ),
          SizedBox(
            height: 14,
          ),
        ]),
        TableRow(children: [
          TextView(
            text: agentLabel.toUpperCase(),
            fontSize: 13,
            textFontWeight: FontWeight.w700,
            textColor: textColorLight,
          ),
          GestureDetector(
            onTap: () {
              if (_status.toLowerCase() != "closed") {
                _closeSnackBars();
                _showAssigneeModal(context, _ticketDetailData, false);
              }
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      color: lightGray),
                  child: Row(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: TextView(
                          text: _ticketDetailData.assignee == null
                              ? notYetAssigned
                              : _ticketDetailData.assignee!.name.toString(),
                          fontSize: 13,
                          textFontWeight: FontWeight.w500,
                          textColor: textColorDark,
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      _status.toLowerCase() != "closed"
                          ? SvgPicture.asset("assets/images/btn_down.svg")
                          : const SizedBox()
                    ],
                  ),
                ),
                const Expanded(child: SizedBox())
              ],
            ),
          ),
        ]),
        const TableRow(children: [
          SizedBox(
            height: 18,
          ),
          SizedBox(
            height: 18,
          ),
        ]),
        TableRow(children: [
          TextView(
            text: reporterLabel.toUpperCase(),
            fontSize: 13,
            textFontWeight: FontWeight.w700,
            textColor: textColorLight,
          ),
          GestureDetector(
            onTap: () {
              if (_status.toLowerCase() != "closed") {
                // _closeSnackBars();
                // _showAssigneeModal(context, _ticketDetailData, true);
              }
            },
            child: TextView(
              text: _ticketDetailData!.user == null
                  ? notYetAssigned
                  : _ticketDetailData!.user!.name
                      .toString()
                      .toLowerCase()
                      .capitalizeString(),
              fontSize: 13,
              textFontWeight: FontWeight.w500,
              textColor: textColorDark,
            ),
          ),
        ]),
      ],
    );
  }

  /*_addTextListeners() {
    _sendFieldFocus.addListener(() {
      console("asdsadasd-> ${_ticketProvider.isSendBtnVisible}");

    });
  }*/

  _closeSnackBars() async {
    if (Get.isSnackbarOpen) {
      await Get.closeCurrentSnackbar();
    }
  }

  _getStatusByName(String id) async {
    _updateTicketStatus(id);
  }

  // void _showStatusModal(BuildContext context, GetOwnOemTicketById response) {
  //   showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       builder: (BuildContext buildContext) {
  //         return Container(
  //           padding: EdgeInsets.only(
  //               bottom: MediaQuery.of(context).viewInsets.bottom),
  //           child: Wrap(
  //             crossAxisAlignment: WrapCrossAlignment.center,
  //             children: <Widget>[
  //               ListTile(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _ticketProvider.setTicketStatus("open");
  //                   _getStatusByName("Open");
  //                 },
  //                 title: Container(
  //                   alignment: Alignment.center,
  //                   child: Text(
  //                     'Open',
  //                     style: TextStyle(
  //                         fontFamily: 'Manrope',
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w500,
  //                         color: textColorLight),
  //                   ),
  //                 ),
  //               ),
  //               line(context),
  //               ListTile(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _ticketProvider.setTicketStatus("Callback");
  //                   _getStatusByName("Callback");
  //                   //_updateTicketStatus(context, response);
  //                 },
  //                 title: Container(
  //                   alignment: Alignment.center,
  //                   child: Text(
  //                     'Callback Scheduled',
  //                     style: TextStyle(
  //                         fontFamily: 'Manrope',
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w500,
  //                         color: textColorLight),
  //                   ),
  //                 ),
  //               ),
  //               line(context),
  //               ListTile(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _ticketProvider.setTicketStatus("Visit planned");
  //                   _getStatusByName("Visit planned");
  //                   //_updateTicketStatus(context, response);
  //                 },
  //                 title: Container(
  //                   alignment: Alignment.center,
  //                   child: Text(
  //                     'Visit Planned',
  //                     style: TextStyle(
  //                         fontFamily: 'Manrope',
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w500,
  //                         color: textColorLight),
  //                   ),
  //                 ),
  //               ),
  //               line(context),
  //               ListTile(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _ticketProvider.setTicketStatus("On hold");
  //                   _getStatusByName("On hold");
  //                   //_updateTicketStatus(context, response);
  //                 },
  //                 title: Container(
  //                   alignment: Alignment.center,
  //                   child: Text(
  //                     'On Hold',
  //                     style: TextStyle(
  //                         fontFamily: 'Manrope',
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w500,
  //                         color: textColorLight),
  //                   ),
  //                 ),
  //               ),
  //               line(context),
  //               ListTile(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _ticketProvider.setTicketStatus("Waiting input");
  //                   _getStatusByName("Waiting input");
  //                   //_updateTicketStatus(context, response);
  //                 },
  //                 title: Container(
  //                   alignment: Alignment.center,
  //                   child: Text(
  //                     'Waiting Input',
  //                     style: TextStyle(
  //                         fontFamily: 'Manrope',
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w500,
  //                         color: textColorLight),
  //                   ),
  //                 ),
  //               ),
  //               line(context),
  //               ListTile(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   _ticketProvider.setTicketStatus("Closed");
  //                   _getStatusByName("Closed");
  //                   //_updateTicketStatus(context, response);
  //                 },
  //                 title: Container(
  //                   alignment: Alignment.center,
  //                   child: Text(
  //                     'Closed',
  //                     style: TextStyle(
  //                         fontFamily: 'Manrope',
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w500,
  //                         color: textColorLight),
  //                   ),
  //                 ),
  //               ),
  //               line(context),
  //               ListTile(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                 },
  //                 title: Container(
  //                   alignment: Alignment.center,
  //                   child: Text(
  //                     'Cancel',
  //                     style: TextStyle(
  //                         fontFamily: 'Manrope',
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w500,
  //                         color: primaryColor),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  // }

  _updateTicketStatus(String status) async {
    //context.showCustomDialog();
    var result = await TicketViewModel()
        .updateTicketStatus(_ticketDetailData.sId.toString() ?? "", status);
    //Navigator.pop(context);
    result.join(
        (failed) => {console("failed => ${failed.exception}")},
        (loaded) => {
              context.showSuccessSnackBar("Work order status updated successfully"),
              _getTicketDetailResponse(),
              setState(() {})
            },
        (loading) => {
              console("loading => "),
            });
  }

  void _showAssigneeModal(
      context, GetOwnOemTicketById response, bool isReporter) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return Container(
            height: MediaQuery.of(context).size.height + 0.5,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    itemCount:
                        responseAssignee.listOwnOemSupportAccounts!.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, i) {
                      return _listFacility(
                          i,
                          context,
                          responseAssignee.listOwnOemSupportAccounts![i],
                          response,
                          isReporter);
                    },
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: textColorDark),
                  ),
                ),
                line(context),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  title: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _listFacility(int i, context, ListOwnOemSupportAccounts assignee,
      GetOwnOemTicketById response, bool isReporter) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        _updateTicketAssignee(assignee.sId.toString(), isReporter);
      },
      title: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Text(
          assignee.name.toString().trim(),
          style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColorDark),
        ),
      ),
    );
  }

  _updateTicketAssignee(String assigneeId, bool isReporter) async {
    context.showCustomDialog();
    // var result = await TicketViewModel().updateTicketAssignee(
    //     _ticketDetailData.sId.toString() ?? "", assigneeId);
    // Navigator.pop(context);
    // result.join(
    //     (failed) => {console("failed => ${failed.exception}")},
    //     (loaded) => {
    //           context.showSuccessSnackBar("Ticket assigned successfully"),
    //           setState(() {})
    //         },
    //     (loading) => {
    //           console("loading => "),
    //         });

    if (isReporter) {
      var result = await TicketViewModel().updateTicketReporter(
          _ticketDetailData.sId.toString() ?? "", assigneeId);
      Navigator.pop(context);
      result.join(
          (failed) => {console("failed => ${failed.exception}")},
          (loaded) => {
                context.showSuccessSnackBar("Work order assigned successfully"),
                setState(() {})
              },
          (loading) => {
                console("loading => "),
              });
    } else {
      var result = await TicketViewModel().updateTicketAssignee(
          _ticketDetailData.sId.toString() ?? "", assigneeId);
      Navigator.pop(context);
      result.join(
          (failed) => {console("failed => ${failed.exception}")},
          (loaded) => {
                context.showSuccessSnackBar("Work order assigned successfully"),
                setState(() {})
              },
          (loading) => {
                console("loading => "),
              });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _sendFieldFocus.dispose();
    super.dispose();
  }
}

class InternalNotesWidget extends StatelessWidget {
  const InternalNotesWidget(
      {super.key,
      required this.messageController,
      required this.sendFieldFocus,
      required this.currentUser,
      required this.sendInternalNotes});

  final TextEditingController messageController;
  final FocusNode sendFieldFocus;
  final CurrentUser currentUser;
  final VoidCallback sendInternalNotes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/picture_circle.svg",
                width: 42,
                height: 42,
              ),
              Text(
                getInitials(currentUser.name.toString()).toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: primaryColor,
                    fontFamily: 'Manrope'),
              )
            ],
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: const BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
              child: TextFormField(
                controller: messageController,
                focusNode: sendFieldFocus,
                autocorrect: false,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                    fontFamily: "Manrope",
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  hintStyle: TextStyle(
                      fontFamily: "Manrope",
                      fontSize: 14,
                      color: textColorLight,
                      fontWeight: FontWeight.w500),
                  hintText: 'Add Internal note',
                  fillColor: Colors.red,
                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Visibility(
            child: GestureDetector(
                onTap: () {
                  sendInternalNotes();
                },
                child: SvgPicture.asset("assets/images/ic-send.svg")),
            //visible: Provider.of<TicketProvider>(context).isSendBtnVisible,
          ),
        ],
      ),
    );
  }
}
