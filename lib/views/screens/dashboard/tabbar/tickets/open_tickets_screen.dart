import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/list_open_tickets_model.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/tickets_view_model.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:makula_oem/views/widgets/makula_ticket_widget.dart';
import 'package:pubnub/pubnub.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OpenTicketsScreen extends StatefulWidget {
  const OpenTicketsScreen({Key? key, required PubnubInstance pubnub})
      : _pubnub = pubnub,
        super(key: key);

  final PubnubInstance _pubnub;

  @override
  _OpenTicketsScreenState createState() => _OpenTicketsScreenState();
}

class _OpenTicketsScreenState extends State<OpenTicketsScreen> {
  ListOpenTickets listOpenTickets = ListOpenTickets();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    //console("initState");
    super.initState();
  }

  void _onRefresh() async {
    await _getFacilityOpenTickets();
    _refreshController.refreshCompleted();
    setState(() {
      listOpenTickets = ListOpenTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      enablePullDown: true,
      enablePullUp: false,
      header: const WaterDropHeader(),
      child: FutureBuilder(
          future: _getFacilityOpenTickets(),
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
                  future: _getMemberShipResults(listOpenTickets),
                  builder: (context, projectSnap) {
                    if (projectSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else {
                      return listOpenTickets.openTicket != null
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
                        "$openTicketsLabel (${listOpenTickets.openTicket!.length})",
                    textColor: textColorLight,
                    textFontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              listOpenTickets.openTicket!.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(6),
                      itemCount: listOpenTickets.openTicket!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return TicketWidget(
                          item: listOpenTickets.openTicket![i],
                        );
                      })
                  : noTicketWidget(context, noOpenTicketLabel)
            ],
          )),
    );
  }

  _getFacilityOpenTickets() async {
    //console("_getFacilityOpenTickets");
    var result = await TicketViewModel().getListOwnOemOpenTickets();
    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {_facilityDetails(loaded.data)},
        (loading) => {
              console("loading => "),
            });
  }

  _facilityDetails(ListOpenTickets data) async {
    listOpenTickets = data;
    //await _getMemberShipResults(data);
  }

  _getMemberShipResults(ListOpenTickets tickets) async {
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
            .where((element) => element.channel.id
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
          custom: {"lastReadTimetoken": "${Timetoken.fromDateTime(newDate)}"}));
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
    listOpenTickets = tickets;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    listOpenTickets = ListOpenTickets();
    super.dispose();
  }
}
