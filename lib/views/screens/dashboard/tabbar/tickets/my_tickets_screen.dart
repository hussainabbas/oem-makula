import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';
import 'package:makula_oem/helper/model/list_user_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_open_tickets_model.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/offline_resources.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/tickets_view_model.dart';
import 'package:makula_oem/main.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/ticket_provider.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:makula_oem/views/widgets/makula_ticket_widget.dart';
import 'package:provider/provider.dart';
import 'package:pubnub/pubnub.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../helper/utils/hive_resources.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key, required PubnubInstance pubnub})
      : _pubnub = pubnub;

  final PubnubInstance _pubnub;

  @override
  _MyTicketsScreenState createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  ListUserOpenTickets? _listOpenTickets = ListUserOpenTickets();
  ListUserCloseTickets? _listUserCloseTickets = ListUserCloseTickets();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final appPreferences = AppPreferences();
  late StatusData? oemStatus;

  //late TicketProvider _tickerProvider;

  _getOEMStatuesValueFromSP() async {
    var abc =  await appDatabase?.oemStatusDao.findAllGetOemStatusesResponses();
    oemStatus = abc?[0];
    // oemStatus =  HiveResources.oemStatusBox?.get(OfflineResources.OEM_STATUS_RESPONSE);
  }

  @override
  void initState() {
    //console("initState");
    _getOEMStatuesValueFromSP();
    super.initState();
  }

  void _onRefresh() async {
    await _getOpenTickets();
    await _getCloseTickets();
    _refreshController.refreshCompleted();
    setState(() {
      _listOpenTickets = ListUserOpenTickets();
      _listUserCloseTickets = ListUserCloseTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    //_tickerProvider = Provider.of<TicketProvider>(context, listen: false);
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      enablePullDown: true,
      enablePullUp: false,
      header: const WaterDropHeader(),
      child: FutureBuilder(
          future: _getOpenTickets(),
          builder: (context, projectSnap) {
            if (projectSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (projectSnap.hasError) {
              return const Center(child: Text(unexpectedError));
            } else {
              return FutureBuilder(
                  future: _getMemberShipResults(_listOpenTickets!),
                  builder: (context, projectSnap) {
                    if (projectSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else {
                      return _listOpenTickets?.openTicket != null
                          ? _myTicketScreenContent()
                          : noTicketWidget(context, noOpenTicketLabel);
                    }
                  });
            }
          }),
    );
  }

  Widget _myTicketScreenContent() {
    return SingleChildScrollView(
      child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8, 0, 0),
                child: TextView(
                    text:
                        "$openTicketsLabel (${_listOpenTickets?.openTicket!.length})",
                    textColor: textColorLight,
                    textFontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              _listOpenTickets?.openTicket?.isNotEmpty == true
                  ? ListView.builder(
                      padding: const EdgeInsets.all(6),
                      itemCount: _listOpenTickets?.openTicket!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return TicketWidget(
                          item: _listOpenTickets?.openTicket![i],
                          statusData: oemStatus,
                        );
                      })
                  : noTicketWidget(context, noOpenTicketLabel),
              _closeTicketContent()
            ],
          )),
    );
  }

  Widget _closeTicketContent() {
    return ChangeNotifierProvider<TicketProvider>(
      create: (context) => TicketProvider(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
        child: Column(
          children: [
            Consumer<TicketProvider>(builder: (context, provider, child) {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                        color: containerColorUnFocused,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    alignment: Alignment.center,
                    child: ListTile(
                      tileColor: containerColorUnFocused,
                      title: Text(
                        "Closed Tickets (${_listUserCloseTickets?.closeTickets == null ? 0 : _listUserCloseTickets?.closeTickets?.length})",
                        style: TextStyle(
                            fontSize: 12,
                            color: textColorDark,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700),
                      ),
                      trailing: Text(
                        provider.isClosedShowing ? "Hide" : "Show",
                        style: TextStyle(
                            color: primaryColor,
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                      onTap: () {
                        provider.setIsClosedValue(!provider.isClosedShowing);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  provider.isClosedShowing
                      ? _listUserCloseTickets?.closeTickets != null
                          ? ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount:
                                  _listUserCloseTickets?.closeTickets?.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, i) {
                                return TicketWidget(
                                  item: _listUserCloseTickets?.closeTickets![i],
                                  statusData: oemStatus,
                                );
                              })
                          : noTicketWidget(context,
                              "There are no close tickets assigned to you.")
                      : Container()
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  _getOpenTickets() async {
    console("_getOpenTickets");
    var isConnected = await isConnectedToNetwork();
    console("_getOpenTickets isConnected -> $isConnected");
    if (isConnected) {
      var result = await TicketViewModel().getListOwnOemUserOpenTickets();
      result.join(
              (failed) => {console("failed => ${failed.exception}")},
              (loaded) => {_openTicketDetails(loaded.data)},
              (loading) =>
          {
            console("loading => "),
          });
      await _getCloseTickets();
    } else {
      try {
        var openTicketList =  await appDatabase?.userOpenTicketListDao.getListUserOpenTickets();
        _listOpenTickets = openTicketList?[0];


        var closeTicketList = await appDatabase?.userCloseTicketListDao.getListUserCloseTickets();
        _listUserCloseTickets = closeTicketList?[0];

      }  catch (e) {
        console("_getOpenTickets => $e");
      }
      console("_getOpenTickets => ${_listOpenTickets?.openTicket?.length}");
    }
  }

  _getCloseTickets() async {
    var isConnected = await isConnectedToNetwork();
    if (isConnected) {
      var result = await TicketViewModel().getListOwnOemUserCloseTickets();
      result.join(
              (failed) => {console("failed => ${failed.exception}")},
              (loaded) => {_closeTicketDetails(loaded.data)},
              (loading) =>
          {
            console("loading => "),
          });
    } else {
      var closeTicketList = await appDatabase?.userCloseTicketListDao.getListUserCloseTickets();
      _listUserCloseTickets = closeTicketList?[0];
      // _listUserCloseTickets = await appDatabase?.userCloseTicketListDao.getListUserCloseTickets();
      console("_getCloseTickets => ${_listOpenTickets?.openTicket?[0].assignee?.name}");
    }
  }

  _openTicketDetails(ListUserOpenTickets data) async {
    await appDatabase?.userOpenTicketListDao.insertListUserOpenTickets(data);
    _listOpenTickets = data;
  }

  _closeTicketDetails(ListUserCloseTickets data) async {
    await appDatabase?.userCloseTicketListDao.insertListUserCloseTickets(data);
    _listUserCloseTickets = data;
  }

  _getMemberShipResults(ListUserOpenTickets tickets) async {
    var isConnected = await isConnectedToNetwork();
    if (isConnected) {
      final Map<String, Timetoken> _channelsWithToken = HashMap();
      List<OpenTicket> unreadList = [];
      List<OpenTicket> newTicket = [];
      List<OpenTicket> readList = [];
      List<String> notFoundList = [];

      var memberShipResult = await widget._pubnub.getMemberships();
      List<MembershipMetadata> foundListFromPN = [];
      for (var item in tickets.openTicket!) {
        if (item.status != "closed") {
          foundListFromPN.addAll(memberShipResult.metadataList!
              .where((element) =>
              element.channel.id
                  .contains(item.ticketChatChannels![0].toString()))
              .toList());
          if (foundListFromPN.isEmpty) {
            notFoundList.add(item.ticketChatChannels![0].toString());
            item.channelsWithCount = 1;
            newTicket.add(item);
          }
        }
      }

      //console("foundListFromPN FOUND => ${foundListFromPN.length}");
      for (var pbItem in foundListFromPN) {
        //console("working = ${pbItem.channel.id} - ${pbItem.custom}");
        if (pbItem.custom != null) {
          if (pbItem.custom['lastReadTimetoken'] != null) {
            var timeToken = pbItem.custom['lastReadTimetoken'];
            _channelsWithToken[pbItem.channel.id] =
                Timetoken(BigInt.parse(timeToken.toString()));
          }
        }
      }
      notFoundList = notFoundList.toSet().toList();
      //console("NOT FOUND => ${notFoundList.length}");
      List<MembershipMetadataInput> channelMetaDataList = [];
      for (var item in notFoundList) {
        //console("notFoundList => $item");
        var date = DateTime.now();
        var newDate = DateTime(date.year, date.month - 1);

        channelMetaDataList.add(MembershipMetadataInput(item.toString(),
            custom: {
              "lastReadTimetoken": "${Timetoken.fromDateTime(newDate)}"
            }));
      }
      widget._pubnub.setMemberships(channelMetaDataList);
      var messageCount =
      await widget._pubnub.getMessagesCount(_channelsWithToken);
      //console("messageCount => ${messageCount.channels}");
      for (var item in tickets.openTicket!) {
        try {
          if (messageCount.channels[item.ticketChatChannels![0]] != null) {
            item.channelsWithCount =
            messageCount.channels[item.ticketChatChannels![0]]!;
          } else {
            item.channelsWithCount = 0;
          }
        } catch (e) {
          //console("item.channelsWithCount e => $e");
          item.channelsWithCount = 0;
        }
      }
      for (var element in tickets.openTicket!) {
        if (element.status != "closed") {
          if (element.channelsWithCount > 0) {
            unreadList.add(element);
          } else {
            readList.add(element);
          }
        }
      }
      tickets.openTicket?.clear();
      tickets.openTicket?.addAll(newTicket);
      tickets.openTicket?.addAll(unreadList);
      tickets.openTicket?.addAll(readList);
      _listOpenTickets = tickets;
    }

  }

  @override
  void dispose() {
    _refreshController.dispose();
    _listOpenTickets = ListUserOpenTickets();
    super.dispose();
  }
}
