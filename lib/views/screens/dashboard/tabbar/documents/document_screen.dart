import 'package:flutter/material.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/views/sliver_app_bar_delegate.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/documents/my_documents_tab_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/documents/templates_tab_screen.dart';
import 'package:makula_oem/views/widgets/makula_custom_app_bar.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({Key? key, required PubnubInstance pubnub})
      : _pubnub = pubnub,
        super(key: key);

  final PubnubInstance _pubnub;

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              CustomAppBar(
                toolbarTitle: documentationLabel,
              ),
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: SliverAppBarDelegate(TabBar(
                  controller: _controller,
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
                      text: myDocumentsLabel,
                    ),
                    Tab(
                      text: templatesLabel,
                    )
                  ],
                )),
              )
            ];
          },
          body: TabBarView(
            controller: _controller,
            children: const <Widget>[
              MyDocumentsTabScreen() ,
              TemplateTabScreen()
            ],
          ),
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
