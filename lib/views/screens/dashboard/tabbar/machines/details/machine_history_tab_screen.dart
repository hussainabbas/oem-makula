import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/machine_ticket_history_model.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/machines_view_model.dart';
import 'package:makula_oem/views/screens/dashboard/dashboard_provider.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/provider/machine_provider.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:makula_oem/views/widgets/ticket_item_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MachineHistoryTabScreen extends StatefulWidget {
  const MachineHistoryTabScreen({Key? key}) : super(key: key);

  @override
  _MachineHistoryTabScreenState createState() =>
      _MachineHistoryTabScreenState();
}

class _MachineHistoryTabScreenState extends State<MachineHistoryTabScreen> {
  MachineTicketHistory _machineTicketHistory = MachineTicketHistory();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  var _machineId = "";

  @override
  void initState() {
    _machineId = context.read<MachineProvider>().machineId;
    context.read<DashboardProvider>().clearChannelId("");
    super.initState();
  }

  void _onRefresh() async {
    await _getMachineHistory();
    _refreshController.refreshCompleted();
    setState(() {
      _machineTicketHistory = MachineTicketHistory();
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
          future: _getMachineHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (snapshot.hasError) {
              return const Center(child: Text(unexpectedError));
            } else {
              return (_machineTicketHistory
                              .listOwnOemMachineTicketHistoryById !=
                          null &&
                      _machineTicketHistory
                          .listOwnOemMachineTicketHistoryById!.isNotEmpty)
                  ? _historyContent()
                  : noMachineWidget(context, noMachineHistory);
            }
          }),
    );
  }

  _getMachineHistory() async {
    console("machineId: $_machineId");
    var result = await MachineViewModel().getMachinesHistoryById(_machineId);

    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {_machineTicketHistory = loaded.data},
        (loading) => {console("loading => ")});
  }

  Widget _historyContent() {
    return SingleChildScrollView(
      child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                  text:
                      "${_machineTicketHistory.listOwnOemMachineTicketHistoryById?.length} "
                      "$ticketsRelatedToThisMachineLabel",
                  textColor: textColorLight,
                  textFontWeight: FontWeight.w600,
                  fontSize: 12),
              const SizedBox(
                height: 16,
              ),
              ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _machineTicketHistory
                        .listOwnOemMachineTicketHistoryById?.length ??
                    0,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  return TicketItemWidget(
                    item: _machineTicketHistory
                        .listOwnOemMachineTicketHistoryById![i],
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Divider(
                  height: 2,
                  color: borderColor,
                ),
              )
            ],
          )),
    );
  }
}
