import 'package:flutter/material.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/helper/utils/utils.dart';
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
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          var connected = await isConnectedToNetwork();
          if (connected) {
            if (context.mounted) {
              Navigator.pushNamed(context, addTicketStep0ScreenRoute);
            }
          } else {
            if (context.mounted) {
              context.showErrorSnackBar(
                  "Couldn't reach the server. Please check your internet connection");
            }
          }

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
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Manrope'),
                labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Manrope'),
                tabs: const [
                  Tab(
                    text: "My Work Orders",
                  ),
                  Tab(
                    text: "Open Work Orders",
                  ),
                  Tab(
                    text: "Closed Work Orders",
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
