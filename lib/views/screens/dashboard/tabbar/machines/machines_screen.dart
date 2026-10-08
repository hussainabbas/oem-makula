import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/get_machine_list_response.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/machines_view_model.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/widgets/makula_custom_app_bar.dart';
import 'package:makula_oem/views/widgets/makula_machine_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MachineScreen extends StatefulWidget {
  const MachineScreen({Key? key, required PubnubInstance pubnub})
      : _pubnub = pubnub,
        super(key: key);

  final PubnubInstance _pubnub;

  @override
  _MachineScreenState createState() => _MachineScreenState();
}

class _MachineScreenState extends State<MachineScreen> {
  GetMachineListResponse _machineListResponse = GetMachineListResponse();

  @override
  void initState() {
    super.initState();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await _getMachinesList();
    _refreshController.refreshCompleted();
    setState(() {
      _machineListResponse = GetMachineListResponse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              CustomAppBar(
                toolbarTitle: machinesLabel,
              )
            ];
          },
          body: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            enablePullDown: true,
            enablePullUp: false,
            header: const WaterDropHeader(),
            child: FutureBuilder(
                future: _getMachinesList(),
                builder: (context, projectSnap) {
                  if (projectSnap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (projectSnap.hasError) {
                    return const Center(child: Text(unexpectedError));
                  } else {
                    return _machineListResponse.listOwnCustomerMachines != null
                        ? _machineContent()
                        : noMachineWidget(context, noMachines);
                  }
                }),
          )),
    );
  }

  Widget _machineContent() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _machineListResponse.listOwnCustomerMachines?.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return MachineWidget(
            item: _machineListResponse.listOwnCustomerMachines![i],
          );
        });
  }

  _getMachinesList() async {
    var result = await MachineViewModel().getMachinesList();
    result.join((failed) => null, (loaded) => _machinesList(loaded.data),
        (loading) => null);
  }

  _machinesList(GetMachineListResponse data) {
    _machineListResponse = data;
  }
}
