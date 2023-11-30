import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:makula_oem/helper/model/chat_message_model.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';
import 'package:makula_oem/helper/model/get_ticket_detail_response.dart';
import 'package:makula_oem/helper/model/list_assignee_response.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/hive_resources.dart';
import 'package:makula_oem/helper/utils/offline_resources.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/tickets_view_model.dart';
import 'package:makula_oem/pubnub/message_provider.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/screens/dashboard/addNewTicket/viewmodel/add_ticket_view_model.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/ticket_provider.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
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
  GetTicketDetailResponse _ticketDetailData = GetTicketDetailResponse();
  CurrentUser _currentUser = CurrentUser();
  // final appPreferences = AppPreferences();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _sendFieldFocus = FocusNode();
  late TicketProvider _ticketProvider;
  PubnubInstance? _pubnubInstance;
  MessageProvider? messageProvider;
  ListAssignee responseAssignee = ListAssignee();
  var _status = "";
  late StatusData? oemStatus;
  //late TicketProvider _tickerProvider;

  _getOEMStatuesValueFromSP() async {
    // oemStatus =
    //     StatusData.fromJson(await appPreferences.getData(AppPreferences.STATUES));
    oemStatus =  HiveResources.oemStatusBox?.get(OfflineResources.OEM_STATUS_RESPONSE);
  }

  @override
  void initState() {
    _ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    _getValuesFromSP();
    _getOEMStatuesValueFromSP();
    //_addTextListeners();
    super.initState();
  }

  void _getValuesFromSP() async {
    // _currentUser =
    //     CurrentUser.fromJson(await appPreferences.getData(AppPreferences.USER));

    _currentUser =  HiveResources.currentUserBox!.get(OfflineResources.CURRENT_USER_RESPONSE)!;
    console("message => ${_currentUser.name}");
  }

  @override
  Widget build(BuildContext context) {
    //_ticket = context.watch<TicketProvider>().ticketItem;
    _pubnubInstance = PubnubInstance(context);
    _pubnubInstance?.setSubscriptionChannel(
        widget._ticket.ticketInternalNotesChatChannels?[0] ?? "");
    messageProvider = MessageProvider(_pubnubInstance!,
        widget._ticket.ticketInternalNotesChatChannels?[0] ?? "");
    return FutureBuilder(
        future: _getTicketDetailResponse(),
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (projectSnap.hasError) {
            return const Center(child: Text(unexpectedError));
          } else {
            return _ticketDetailData.getOwnOemTicketById != null
                ? _ticketOverviewContent()
                : Container();
          }
        });
  }

  _getTicketDetailResponse() async {
    var result =
        await TicketViewModel().getTicketById(widget._ticket.sId.toString());
    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {
          _getStatus(loaded.data)
          //     _ticketDetailData = loaded.data,
          // _getStatus(_ticketDetailData.getOwnOemTicketById?.status.toString() ?? "")
            },
        (loading) => {
              console("loading => "),
            });

    await getListOwnOemSupportAccounts();
  }

  _getStatus(GetTicketDetailResponse response) async {
    var statusData = await getStatusById(response.getOwnOemTicketById?.status.toString() ?? "");
    _status = statusData?.label ?? "";
    _ticketDetailData = response;
  }

  getListOwnOemSupportAccounts() async {
    var result = await AddTicketViewModel().getListOwnOemSupportAccounts();
    result.join(
        (failed) => {console("failed => ${failed.exception}")},
        (loaded) => {
              responseAssignee = loaded.data,
            },
        (loading) => {
              console("loading => "),
            });
  }

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
                              "${_ticketDetailData.getOwnOemTicketById?.title?.capitalizeString()}",
                          textColor: textColorDark,
                          textFontWeight: FontWeight.w600,
                          fontSize: 17),
                      const SizedBox(
                        height: 8,
                      ),
                      TextView(
                          text:
                              "${_ticketDetailData.getOwnOemTicketById?.machine?.name?.capitalizeString()} "
                              " •  ${_ticketDetailData.getOwnOemTicketById?.machine?.serialNumber.toString()}",
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
                      ReadMoreText(
                        _ticketDetailData.getOwnOemTicketById?.description
                                .toString() ??
                            "",
                        colorClickableText: primaryColor,
                        trimCollapsedText: '...Read more',
                        trimExpandedText: ' Read less',
                        style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                //_ticketDetailWidgets(response),
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
        _status != "Closed"
            ? Container(
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
                          getInitials(_currentUser.name.toString())
                              .toUpperCase(),
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
                          controller: _messageController,
                          focusNode: _sendFieldFocus,
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
                            contentPadding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                            _sendInternalNotes();
                          },
                          child: SvgPicture.asset("assets/images/ic-send.svg")),
                      //visible: Provider.of<TicketProvider>(context).isSendBtnVisible,
                    ),
                  ],
                ),
              )
            : Container()
        //_internalNotesFormPN()
      ],
    );
  }

  void _sendInternalNotes() async {
    if (_messageController.text.isNotEmpty) {
      context.showCustomDialog();
      await messageProvider!.sendMessage(
          widget._ticket.ticketInternalNotesChatChannels![0],
          _messageController.text);
      _messageController.text = "";
      Navigator.pop(context);
      context.showSuccessSnackBar("Internal Note Saved");
    }
  }

  Widget _internalNotesFormPN() {
    return ChangeNotifierProvider<MessageProvider>(
      create: (context) => messageProvider!,
      child: Consumer<MessageProvider>(builder: (context, value, child) {
        return _internalNotesListView(value.messages);
      }),
    );
  }

  Widget _internalNotesListView(List<ChatMessage> _messageList) {
    List<ChatMessage> list = [];
    list.addAll(_messageList.reversed);
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
            text: _ticketDetailData.getOwnOemTicketById?.createdAt?.formatDate(
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
            text: ticketID(
                _ticketDetailData.getOwnOemTicketById?.ticketId.toString() ??
                    ""),
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
            onTap: () {
              if (_status != "Closed") {
                _closeSnackBars();
                _showStatusModal(context, _ticketDetailData);
              }
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      color: getStatusContainerColor(_status)),
                  child: Text(
                    _status.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Manrope',
                        color: getStatusColor(_status),
                        fontSize: 14),
                  ),
                ),
                const Expanded(child: SizedBox())
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
              if (_status != "Closed") {
                _closeSnackBars();
                _showAssigneeModal(context, _ticketDetailData);
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
                          text:
                              _ticketDetailData.getOwnOemTicketById!.assignee ==
                                      null
                                  ? notYetAssigned
                                  : _ticketDetailData
                                      .getOwnOemTicketById!.assignee!.name
                                      .toString(),
                          fontSize: 13,
                          textFontWeight: FontWeight.w500,
                          textColor: textColorDark,
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      _status != "Closed"
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
          TextView(
            text: _ticketDetailData.getOwnOemTicketById!.user == null
                ? notYetAssigned
                : _ticketDetailData.getOwnOemTicketById!.user!.name
                    .toString()
                    .toLowerCase()
                    .capitalizeString(),
            fontSize: 13,
            textFontWeight: FontWeight.w500,
            textColor: textColorDark,
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

  _getStatusByName(String status) async {
    var statusData = await getStatusByName(status);
    _updateTicketStatus(statusData?.sId ?? "");
  }

  void _showStatusModal(
      BuildContext context, GetTicketDetailResponse response) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext buildContext) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _ticketProvider.setTicketStatus("open");
                    _getStatusByName("Open");
                  },
                  title: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Open',
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColorLight),
                    ),
                  ),
                ),
                line(context),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _ticketProvider.setTicketStatus("Callback");
                    _getStatusByName("Callback");
                    //_updateTicketStatus(context, response);
                  },
                  title: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Callback Scheduled',
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColorLight),
                    ),
                  ),
                ),
                line(context),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _ticketProvider.setTicketStatus("Visit planned");
                    _getStatusByName("Visit planned");
                    //_updateTicketStatus(context, response);
                  },
                  title: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Visit Planned',
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColorLight),
                    ),
                  ),
                ),
                line(context),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _ticketProvider.setTicketStatus("On hold");
                    _getStatusByName("On hold");
                    //_updateTicketStatus(context, response);
                  },
                  title: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'On Hold',
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColorLight),
                    ),
                  ),
                ),
                line(context),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _ticketProvider.setTicketStatus("Waiting input");
                    _getStatusByName("Waiting input");
                    //_updateTicketStatus(context, response);
                  },
                  title: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Waiting Input',
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColorLight),
                    ),
                  ),
                ),
                line(context),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _ticketProvider.setTicketStatus("Closed");
                    _getStatusByName("Closed");
                    //_updateTicketStatus(context, response);
                  },
                  title: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Closed',
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColorLight),
                    ),
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

  _updateTicketStatus(String status) async {
    //context.showCustomDialog();
    var result = await TicketViewModel().updateTicketStatus(
        _ticketDetailData.getOwnOemTicketById?.sId.toString() ?? "", status);
    //Navigator.pop(context);
    result.join(
        (failed) => {console("failed => ${failed.exception}")},
        (loaded) =>
            {
              context.showSuccessSnackBar("Ticket moved to $status tickets!"),
              _getTicketDetailResponse(),
              setState(() {

              })
            },
        (loading) => {
              console("loading => "),
            });
  }

  void _showAssigneeModal(context, GetTicketDetailResponse response) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext buildContext) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Wrap(
              children: <Widget>[
                ListView.separated(
                  itemCount: responseAssignee.listOwnOemSupportAccounts!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, i) {
                    return _listFacility(
                        i,
                        context,
                        responseAssignee.listOwnOemSupportAccounts![i],
                        response);
                  },
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: textColorDark),
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
      GetTicketDetailResponse response) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        _updateTicketAssignee(assignee.sId.toString());
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

  _updateTicketAssignee(String assigneeId) async {
    context.showCustomDialog();
    var result = await TicketViewModel().updateTicketAssignee(
        _ticketDetailData.getOwnOemTicketById?.sId.toString() ?? "",
        assigneeId);
    Navigator.pop(context);
    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {
              context.showSuccessSnackBar("Ticket assigned successfully"),
              setState(() {})
            },
        (loading) => {
              console("loading => "),
            });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _sendFieldFocus.dispose();
    super.dispose();
  }
}
