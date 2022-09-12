import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';

class AppBarCustom extends StatelessWidget {
  const AppBarCustom(
      {Key? key, required String title, String? screenRoute = ""})
      : _title = title,
        _screenRoute = screenRoute,
        super(key: key);

  final String _title;
  final String? _screenRoute;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: true,
        elevation: 0,
        shadowColor: borderColor,
        backgroundColor: containerColorUnFocused,
        foregroundColor: textColorDark,
        leading: IconButton(
          icon: SvgPicture.asset("assets/images/ic_back.svg",
              color: textColorDark),
          onPressed: () {
            Navigator.pop(context);
            /*Navigator.popUntil(
                context, ModalRoute.withName(dashboardScreenRoute));*/
          },
        ),
        title: TextView(
            text: _title,
            fontSize: 17,
            textColor: textColorDark,
            textFontWeight: FontWeight.w600));
  }
}
