import 'package:flutter/material.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/details/machine_details_tab_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/details/machine_documentation_tab_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/details/machine_history_tab_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/provider/machine_provider.dart';
import 'package:makula_oem/views/widgets/makula_app_bar_gray.dart';
import 'package:provider/provider.dart';

class MachineDetailsScreen extends StatefulWidget {
  const MachineDetailsScreen({Key? key}) : super(key: key);

  @override
  _MachineDetailsScreenState createState() => _MachineDetailsScreenState();
}

class _MachineDetailsScreenState extends State<MachineDetailsScreen>
    with SingleTickerProviderStateMixin {
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
      body: Column(
        children: [
          AppBarCustom(
            title: context.watch<MachineProvider>().machineName,
            screenRoute: machineDetailScreenRoute,
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
              controller: controller,
              labelColor: primaryColor,
              indicatorColor: primaryColor,
              unselectedLabelColor: textColorLight,
              unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Manrope'),
              labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope'),
              tabs: const [
                Tab(
                  text: detailsLabel,
                ),
                Tab(
                  text: documentationLabel,
                ),
                Tab(
                  text: historyLabel,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Expanded(
              child: TabBarView(
            controller: controller,
            children: const [
              MachineDetailsTabScreen(),
              MachineDocumentationScreen(),
              MachineHistoryTabScreen()
            ],
          ))
        ],
      ),
    );
  }
}
