

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget {
  CustomAppBar({
    Key? key,
    required String toolbarTitle,
  })  : _toolBarTitle = toolbarTitle,
        super(key: key);

  final String _toolBarTitle;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: _toolbar2(context),
          background: Image.asset(
            "assets/images/Background_appbar.png",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
          )),
      centerTitle: true,
      backgroundColor: primaryColor,
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
      expandedHeight: 130,
      toolbarHeight: 70,
    );
  }

  Widget _toolbar2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextView(
              text: _toolBarTitle,
              textColor: Colors.white,
              textFontWeight: FontWeight.w700,
              fontSize: 32),
          GestureDetector(
            onTap: () {
              _showMenuModal(context);
            },
            child: SvgPicture.asset(
              "assets/images/icon_button.svg",
              width: 30,
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext buildContext) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  onTap: () {
                    _logout(context);
                  },
                  title: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                line(context),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  title: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _logout(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
    Navigator.of(context).pushNamedAndRemoveUntil(
        loginScreenRoute, (Route<dynamic> route) => false);
  }
}
