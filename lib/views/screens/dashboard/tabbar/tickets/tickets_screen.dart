import 'package:flutter/material.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/helper/views/sliver_app_bar_delegate.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/closed_tickets_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/my_tickets_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/open_tickets_screen.dart';
import 'package:makula_oem/views/widgets/makula_custom_app_bar.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({Key? key, required PubnubInstance pubnub})
      : _pubnub = pubnub,
        super(key: key);

  final PubnubInstance _pubnub;

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen>
    with TickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(
      length: 3,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, addTicketStep0ScreenRoute);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            CustomAppBar(
              toolbarTitle: ticketsLabel,
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: SliverAppBarDelegate(TabBar(
                controller: controller,
                isScrollable: false,
                labelColor: primaryColor,
                indicatorColor: primaryColor,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                    text: myTicketLabel,
                  ),
                  Tab(
                    text: openTicketsLabel,
                  ),
                  Tab(
                    text: closedTicketsLabel,
                  ),
                ],
              )),
            )
          ];
        },
        body: TabBarView(
          controller: controller,
          children: <Widget>[
            MyTicketsScreen(pubnub: widget._pubnub),
            OpenTicketsScreen(pubnub: widget._pubnub),
            ClosedTicketsScreen(pubnub: widget._pubnub),
          ],
        ),
      ),
    );
  }
}
