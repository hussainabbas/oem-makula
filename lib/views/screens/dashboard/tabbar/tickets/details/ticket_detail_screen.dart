import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/chat_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/ticket_overview_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/ticket_provider.dart';
import 'package:makula_oem/views/widgets/makula_app_bar_gray.dart';
import 'package:provider/provider.dart';

class TicketDetailScreen extends StatefulWidget {
  TicketDetailScreen({Key? key, required String channelId, required OpenTicket ticket})
      : _ticket = ticket,
        _channelId = channelId,
        super(key: key);

  OpenTicket _ticket;
  String _channelId;

  @override
  _TicketDetailScreenState createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  //OpenTicket _ticket = OpenTicket();

  @override
  void initState() {
    _controller = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   // _ticket = context.watch<TicketProvider>().ticketItem;
    return WillPopScope(
      onWillPop: () async {
        //Navigator.popUntil(context, ModalRoute.withName(dashboardScreenRoute));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            AppBarCustom(
              title: widget._ticket.ticketId.toString().isNotEmpty
                  ? widget._ticket.ticketId.toString()
                  : ticketLabel,
              screenRoute: ticketDetailScreenRoute,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: borderColor,
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: TabBar(
                controller: _controller,
                labelColor: primaryColor,
                indicatorColor: primaryColor,
                unselectedLabelColor: textColorLight,
                unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Manrope'),
                labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Manrope'),
                tabs: const [

                  Tab(
                    text: ticketOverViewLabel,
                  ),
                  Tab(
                    text: chatLabel,
                  ),
                ],
              ),
            ),
            Expanded(
                child: TabBarView(
              controller: _controller,
              children: [
                TicketOverviewScreen(ticket: widget._ticket, channelId: widget._channelId,),
                ChatScreen(ticket: widget._ticket, channelId: widget._channelId,),
              ],
            ))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
