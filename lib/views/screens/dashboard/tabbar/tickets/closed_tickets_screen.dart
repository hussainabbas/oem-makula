import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/list_close_tickets_model.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/tickets_view_model.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:makula_oem/views/widgets/makula_ticket_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ClosedTicketsScreen extends StatefulWidget {
  const ClosedTicketsScreen({Key? key, required PubnubInstance pubnub})
      : _pubnub = pubnub,
        super(key: key);

  final PubnubInstance _pubnub;

  @override
  _ClosedTicketsScreenState createState() => _ClosedTicketsScreenState();
}

class _ClosedTicketsScreenState extends State<ClosedTicketsScreen> {
  var itemSize = 1;

  ListCloseTickets _listCloseTickets = ListCloseTickets();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
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
              return _listCloseTickets.closeTickets != null
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
                        "$closedTicketsLabel (${_listCloseTickets.closeTickets!.length})",
                    textColor: textColorLight,
                    textFontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              _listCloseTickets.closeTickets != null
                  ? ListView.builder(
                      padding: const EdgeInsets.all(6),
                      itemCount: _listCloseTickets.closeTickets!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return TicketWidget(
                          item: _listCloseTickets.closeTickets![i],
                        );
                      })
                  : noTicketWidget(context, noCloseTicketLabel)
            ],
          )),
    );
  }

  _getFacilityCloseTickets() async {
    var result = await TicketViewModel().getListOwnFacilityCloseTickets();
    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {_facilityDetails(loaded.data)},
        (loading) => {
              console("loading => "),
            });
  }

  _facilityDetails(ListCloseTickets data) {
    console("_facilityDetails => ${data.closeTickets?.length.toString()}");
    _listCloseTickets = data;
  }

  @override
  void dispose() {
    _listCloseTickets = ListCloseTickets();
    _refreshController.dispose();
    super.dispose();
  }
}
