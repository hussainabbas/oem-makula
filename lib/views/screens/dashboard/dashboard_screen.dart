import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/hive_resources.dart';
import 'package:makula_oem/helper/utils/offline_resources.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/main.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/screens/dashboard/dashboard_provider.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/documents/document_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/machines_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/tickets_screen.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController controller;
  PubnubInstance? _pubnubInstance;
  //final appPreferences = AppPreferences();

  @override
  void initState() {
    _getValueFromSP(context);
    controller = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  _getValueFromSP(BuildContext context) async {
    // var userValue =
    //     CurrentUser.fromJson(await appPreferences.getData(AppPreferences.USER));

    var userValue = await appDatabase?.userDao.getCurrentUserDetailsFromDb();
    console(
        "userValue.chatToken.toString(), = > ${userValue?.chatToken.toString()}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().setChatDetails(
        userValue?.chatToken.toString() ?? "",
        userValue?.chatKeys?.subscribeKey.toString() ?? "",
        userValue?.chatKeys?.publishKey.toString() ?? "",
        userValue?.chatUUID.toString() ?? "",
      );

      // Move the PubnubInstance initialization here
      setState(() {
        _pubnubInstance = PubnubInstance(context);
      });
    });
    // context.read<DashboardProvider>().setChatDetails(
    //     userValue?.chatToken.toString() ?? "",
    //     userValue?.chatKeys!.subscribeKey.toString() ?? "",
    //     userValue?.chatKeys!.publishKey.toString() ?? "",
    //     userValue?.chatUUID.toString() ?? "");
    // setState(() {
    //   _pubnubInstance = PubnubInstance(context);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.index == 0) {
          return true;
        } else {
          setState(() {
            controller.index = 0;
          });
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: DecoratedBox(
          decoration:
              BoxDecoration(border: Border.all(width: 1, color: borderColor)),
          child: TabBar(
            controller: controller,
            isScrollable: false,
            labelColor: primaryColor,
            indicatorColor: Colors.white,
            labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
            unselectedLabelColor: textColorLight,
            unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Manrope'),
            labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Manrope'),
            onTap: (index) {
              setState(() {
                controller.index = index;
              });
            },
            tabs: [
              Tab(
                  text: ticketsLabel,
                  icon: SvgPicture.asset("assets/images/tickets.svg",
                      color:
                          controller.index == 0 ? primaryColor : Colors.grey)),
              Tab(
                  text: documentationLabel,
                  icon: controller.index == 1
                      ? SvgPicture.asset("assets/images/document_selected.svg")
                      : SvgPicture.asset(
                          "assets/images/document_selected.svg",
                          color: Colors.grey,
                        )),
              /*Tab(
                  text: settingsLabel,
                  icon: controller.index == 2
                      ? SvgPicture.asset("assets/images/ic-settings-filled.svg")
                      : SvgPicture.asset("assets/images/ic-settings.svg")),*/
            ],
          ),
        ),
        /* floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            Navigator.pushNamed(context, addTicketStep1ScreenRoute);
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),*/
        body: TabBarView(
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _pubnubInstance != null
                ? TicketsScreen(
                    pubnub: _pubnubInstance!,
                  )
                : const Center(child: CircularProgressIndicator.adaptive()),
            _pubnubInstance != null
                ? DocumentScreen(
                    pubnub: _pubnubInstance!,
                  )
                : const Center(child: CircularProgressIndicator.adaptive()),
            /*_pubnubInstance != null
                ? SettingScreen(
                    pubnub: _pubnubInstance!,
                  )
                : const Center(child: CircularProgressIndicator.adaptive()),*/
          ],
        ),
      ),
    );
  }
}
