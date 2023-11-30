import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/hive_resources.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/pubnub/pubnub_instance.dart';
import 'package:makula_oem/views/widgets/makula_custom_app_bar.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key, required PubnubInstance pubnub})
      : _pubnub = pubnub,
        super(key: key);

  final PubnubInstance _pubnub;

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // final _appPreferences = AppPreferences();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              CustomAppBar(
                toolbarTitle: settingsLabel,
              )
            ];
          },
          body: _settingContent()),
    );
  }

  Widget _settingContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
              text: generalSettingsLabel.toUpperCase(),
              textColor: textColorLight,
              textFontWeight: FontWeight.w600,
              fontSize: 12),
          const SizedBox(
            height: 8,
          ),
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/rectangle.svg",
                ),
                SvgPicture.asset(
                  "assets/images/language.svg",
                ),
              ],
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                    text: languageLabel,
                    textColor: textColorDark,
                    textFontWeight: FontWeight.w700,
                    fontSize: 13),
                const SizedBox(
                  height: 6,
                ),
                TextView(
                    text: englishLabel,
                    textColor: textColorLight,
                    textFontWeight: FontWeight.w500,
                    fontSize: 11),
              ],
            ),
            trailing: SvgPicture.asset("assets/images/ic_next.svg"),
          ),
          const SizedBox(
            height: 24,
          ),
          GestureDetector(
            onTap: () {
              _showMenuModal();
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
              alignment: Alignment.centerLeft,
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              child: TextView(
                  text: logoutLabel,
                  textColor: redBorderColor,
                  textFontWeight: FontWeight.w700,
                  fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  showLogoutAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: TextView(
          text: yesLabel,
          textColor: redBorderColor,
          textFontWeight: FontWeight.w700,
          fontSize: 14),
      onPressed: () {
        HiveResources.flush();
        //_appPreferences.clear();
        Navigator.of(context).pushNamedAndRemoveUntil(
            loginScreenRoute, (Route<dynamic> route) => false);
      },
    );

    Widget cancelButton = TextButton(
      child: TextView(
          text: cancelLabel,
          textColor: textColorLight,
          textFontWeight: FontWeight.w700,
          fontSize: 14),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: TextView(
          text: logoutLabel,
          textColor: redBorderColor,
          textFontWeight: FontWeight.w700,
          fontSize: 14),
      content: TextView(
          text: areYouSureLogout,
          textColor: textColorDark,
          textFontWeight: FontWeight.w700,
          fontSize: 14),
      actions: [
        cancelButton,
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showMenuModal() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext buildContext) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Wrap(
              children: <Widget>[
                const SizedBox(
                  height: 8,
                ),
                Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: MediaQuery.of(context).size.width,
                    child: SvgPicture.asset("assets/images/ic_small_line.svg")),
                ListTile(
                  onTap: () {
                    HiveResources.flush();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        loginScreenRoute, (Route<dynamic> route) => false);
                  },
                  title: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      logoutLabel,
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
}
