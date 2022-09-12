import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/get_machine_details_response.dart';
import 'package:makula_oem/helper/model/get_machine_folder_id.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/flavor_const.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/machines_view_model.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/provider/machine_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MachineDocumentationScreen extends StatefulWidget {
  const MachineDocumentationScreen({Key? key}) : super(key: key);

  @override
  State<MachineDocumentationScreen> createState() =>
      _MachineDocumentationScreenState();
}

class _MachineDocumentationScreenState
    extends State<MachineDocumentationScreen> {
  GetMachineFolderIdResponse _machineFolderIdResponse =
      GetMachineFolderIdResponse();
  GetMachineDetailResponse _machineDetailResponse = GetMachineDetailResponse();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final appPreferences = AppPreferences();



  void _onRefresh() async {
    await _getMachineDetails();
    await _getMachineFolderById();
    _refreshController.refreshCompleted();
    setState(() {
      _machineDetailResponse = GetMachineDetailResponse();
      _machineFolderIdResponse = GetMachineFolderIdResponse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: FutureBuilder(
          future: _getMachineDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            if (snapshot.hasError) {
              return const Center(child: Text(unexpectedError));
            } else {
              return FutureBuilder(
                  future: _getMachineFolderById(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text(unexpectedError));
                    } else {
                      return _machineDetailContent();
                    }
                  });
            }
          }),
    );
  }

  _getMachineDetails() async {
    var result = await MachineViewModel().getMachinesDetailsById(
        Provider.of<MachineProvider>(context, listen: false).machineId);

    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {_machineDetailResponse = loaded.data},
        (loading) => {console("loading => ")});
  }

  _getMachineFolderById() async {
    var result = await MachineViewModel().getMachinesFolderById(
        Provider.of<MachineProvider>(context, listen: false).machineId);

    result.join(
        (failed) => {console("failed => " + failed.exception.toString())},
        (loaded) => {
              _machineFolderIdResponse = loaded.data!,
              console(
                  "Success => ${_machineFolderIdResponse.getMachineFolderId}")
            },
        (loading) => {console("loading => ")});
  }

  Widget _machineDetailContent() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(0),
        height: MediaQuery.of(context).size.height * 0.78,
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          enablePullDown: true,
          enablePullUp: false,
          header: const WaterDropHeader(),
          child: Container()
        ));
  }


  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
