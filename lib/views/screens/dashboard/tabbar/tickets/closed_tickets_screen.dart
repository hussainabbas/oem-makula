import 'package:flutter/material.dart';
import 'package:makula_oem/helper/graphQL/api_calls.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';
import 'package:makula_oem/helper/model/list_close_tickets_model.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/hive_resources.dart';
import 'package:makula_oem/helper/utils/offline_resources.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/tickets_view_model.dart';
import 'package:makula_oem/main.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:makula_oem/views/widgets/makula_ticket_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ClosedTicketsScreen extends StatefulWidget {
  const ClosedTicketsScreen({super.key, required PubnubInstance pubnub})
      : _pubnub = pubnub;

  final PubnubInstance _pubnub;

  @override
  _ClosedTicketsScreenState createState() => _ClosedTicketsScreenState();
}

class _ClosedTicketsScreenState extends State<ClosedTicketsScreen> {
  var itemSize = 1;

  ListCloseTickets? _listCloseTickets = ListCloseTickets();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  // final appPreferences = AppPreferences();
  late StatusData? oemStatus;
  //late TicketProvider _tickerProvider;

  _getOEMStatuesValueFromSP() async {
    var abc =  await appDatabase?.oemStatusDao.findAllGetOemStatusesResponses();
    oemStatus = abc?[0];
  }


  @override
  void initState() {
    _getOEMStatuesValueFromSP();
    super.initState();
  }

  void _onRefresh() async {
    await _getFacilityCloseTickets();
    _refreshController.refreshCompleted();
    setState(() {
      _listCloseTickets = ListCloseTickets();
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
          future: _getFacilityCloseTickets(),
          builder: (context, projectSnap) {
            if (projectSnap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            if (projectSnap.hasError) {
              return const Center(child: Text(unexpectedError));
            } else {
              return _listCloseTickets?.closeTickets != null
                  ? _closeTicketScreenContent()
                  : noTicketWidget(context, noCloseTicketLabel);
            }
          }),
    );
  }

  Widget _closeTicketScreenContent() {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8, 0, 0),
                child: TextView(
                    text:
                        "$closedTicketsLabel (${_listCloseTickets?.closeTickets!.length})",
                    textColor: textColorLight,
                    textFontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              _listCloseTickets?.closeTickets != null
                  ? ListView.builder(
                      padding: const EdgeInsets.all(6),
                      itemCount: _listCloseTickets?.closeTickets!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return TicketWidget(
                          item: _listCloseTickets?.closeTickets![i],
                          statusData: oemStatus,
                        );
                      })
                  : noTicketWidget(context, noCloseTicketLabel)
            ],
          )),
    );
  }

  _getFacilityCloseTickets() async {
    var isConnected = await isConnectedToNetwork();
    if (isConnected) {
      var result = await TicketViewModel().getListOwnFacilityCloseTickets();
      result.join(
              (failed) => {console("failed => ${failed.exception}")},
              (loaded) => {_facilityDetails(loaded.data)},
              (loading) => {
            console("loading => "),
          });
    } else {
      // _listCloseTickets = await appDatabase?.listCloseTicketsDao.getListCloseTickets();

      var closeTicketList = await appDatabase?.listCloseTicketsDao.getListCloseTickets();
      _listCloseTickets = closeTicketList?[0];
    }

  }

  _facilityDetails(ListCloseTickets data)async {
    console("_facilityDetails => ${data.closeTickets?.length.toString()}");
    await appDatabase?.listCloseTicketsDao.insertListCloseTickets(data);
    _listCloseTickets = data;
  }

  @override
  void dispose() {
    _listCloseTickets = ListCloseTickets();
    _refreshController.dispose();
    super.dispose();
  }
}
