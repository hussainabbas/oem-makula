import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/get_machine_details_response.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/flavor_const.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/machines_view_model.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/provider/machine_provider.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readmore/readmore.dart';

class MachineDetailsTabScreen extends StatefulWidget {
  const MachineDetailsTabScreen({Key? key}) : super(key: key);

  @override
  _MachineDetailsTabScreenState createState() =>
      _MachineDetailsTabScreenState();
}

class _MachineDetailsTabScreenState extends State<MachineDetailsTabScreen> {
  GetMachineDetailResponse _machineDetailResponse = GetMachineDetailResponse();

  /*GetMachineFolderIdResponse _machineFolderIdResponse =
      GetMachineFolderIdResponse();*/
  /*Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _webViewController;*/
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final appPreferences = AppPreferences();

  void _onRefresh() async {
    await _getMachineDetails();
    //await _getMachineFolderById();
    _refreshController.refreshCompleted();
    setState(() {
      _machineDetailResponse = GetMachineDetailResponse();
      //_controller = Completer<WebViewController>();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //_provider = Provider.of<MachineProvider>(context, listen: false);
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
              return _machineDetailContent();
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

  /* _getMachineFolderById() async {
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
  }*/

  Widget _machineDetailContent() {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      enablePullDown: true,
      enablePullUp: false,
      header: const WaterDropHeader(),
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
            child: PrimaryScrollController(
          controller: ScrollController(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: (_machineDetailResponse.getOwnCustomerMachineById?.image == null ||
                            _machineDetailResponse.getOwnCustomerMachineById?.image?.isEmpty ==
                                true) &&
                        (_machineDetailResponse.getOwnCustomerMachineById?.customers?[0].oem?.thumbnail == null ||
                            _machineDetailResponse.getOwnCustomerMachineById
                                    ?.customers?[0].oem?.thumbnail?.isEmpty ==
                                true)
                    ? defaultImageBig(context)
                    : CachedNetworkImage(
                        height: 200,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        placeholder: (context, url) => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            ),
                        errorWidget: (context, url, error) => defaultImageBig(context),
                        httpHeaders: const {'Referer': referer},
                        imageUrl: _machineDetailResponse.getOwnCustomerMachineById?.image != null ||
                                _machineDetailResponse.getOwnCustomerMachineById
                                        ?.image?.isEmpty !=
                                    true
                            ? _machineDetailResponse.getOwnCustomerMachineById!.image
                                .toString()
                            : _machineDetailResponse.getOwnCustomerMachineById!
                                .customers![0].oem!.thumbnail
                                .toString()), /*Image.memory(
                            decodeBase64(_machineDetailResponse
                                .getOwnCustomerMachineById!.image
                                .toString()),
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),*/
              ),
              const SizedBox(
                height: 18,
              ),
              TextView(
                  text: _machineDetailResponse.getOwnCustomerMachineById!.name
                      .toString(),
                  textColor: textColorDark,
                  textFontWeight: FontWeight.w700,
                  fontSize: 17),
              const SizedBox(
                height: 6,
              ),
              TextView(
                  text: _machineDetailResponse
                      .getOwnCustomerMachineById!.serialNumber
                      .toString(),
                  textColor: textColorLight,
                  textFontWeight: FontWeight.w500,
                  fontSize: 14),
              const SizedBox(
                height: 24,
              ),
              ReadMoreText(
                _machineDetailResponse.getOwnCustomerMachineById!.description
                    .toString(),
                colorClickableText: primaryColor,
                trimCollapsedText: '...Read more',
                trimExpandedText: ' Read less',
                style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              /*const SizedBox(
                height: 24,
              ),
              TextView(
                  text: machineDocumentationLabel,
                  textColor: textColorDark,
                  textFontWeight: FontWeight.w700,
                  fontSize: 12),*/
              /* const SizedBox(
                height: 12,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 580.0),
                child: WebView(
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  gestureRecognizers: gestureRecognizers,
                  */ /*<Factory<OneSequenceGestureRecognizer>>{
                          Factory<HorizontalDragGestureRecognizer>(
                            () => HorizontalDragGestureRecognizer()
                              ..onUpdate = (_) {},
                          ),
                          Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer()
                              ..onUpdate = (_) {},
                          ),
                          Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer())
                        },*/ /*
                  debuggingEnabled: false,
                  zoomEnabled: false,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
                    _webViewController = webViewController;
                    _onLoadHtmlStringExample(webViewController, context);
                  },
                ),
              ),*/
              /*_machineDetailResponse.getOwnCustomerMachineById?.documentTree !=
                      null
                  ? ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: _machineDetailResponse
                          .getOwnCustomerMachineById
                          ?.documentTree
                          ?.dataTreeFacilityMobile
                          ?.documents![0]
                          .childs
                          ?.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return MakulaExpansionTile(
                          document: _machineDetailResponse
                              .getOwnCustomerMachineById!
                              .documentTree!
                              .dataTreeFacilityMobile!
                              .documents![0]
                              .childs![i],
                        );
                      })
                  : noMachineDocumentationWidget(
                      context, noMachineDocumentationLabel)*/
            ],
          ),
        )),
      ),
    );
  }

/*final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };*/

/* Future<void> _onLoadHtmlStringExample(
      WebViewController controller, BuildContext context) async {
    var userValue =
        CurrentUser.fromJson(await appPreferences.getData(AppPreferences.USER));

    await controller.loadUrl(
        "https://oem-staging.makula.io/mobile/folders?userId=${userValue.sId}"
        "&folderAccessToken=${userValue.foldersAccessToken}"
        "&folderId=${_machineFolderIdResponse.getMachineFolderId}"
        "&machineId=${_machineDetailResponse.getOwnCustomerMachineById?.sId}"); //loadHtmlString(htmlData);
  }*/
}
