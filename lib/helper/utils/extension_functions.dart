

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/utils.dart';

extension FormatDate on String {
  String formatDate(String inFormat, String outFormat) {
    DateTime parseDate = DateFormat(inFormat).parse(this);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat(outFormat);
    return outputFormat.format(inputDate);
  }
}

extension StringExtension on String {
  String capitalizeString() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension SnackbarExtension on BuildContext {
  void showSuccessSnackBar(String msg) {
    /*ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      backgroundColor: greenColor,
      content: Row(
        children: [
          SvgPicture.asset('assets/images/tick.svg'),
          const SizedBox(width: 16,),
          Text(msg),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(this).size.height - 200,
          right: 20,
          left: 20),
    ));*/

    Get.snackbar("Success", msg,
        backgroundColor: greenColor,
        colorText: Colors.white,
        borderRadius: 0,
        animationDuration: const Duration(microseconds: 0),
        icon: SvgPicture.asset('assets/images/tick.svg'),
        duration: const Duration(seconds: 2));
  }
  void showErrorSnackBar(String msg) {
    final snackBar = SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(msg),
        backgroundColor: redStatusColor);
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}

extension Conversion on String {
  String convertStringToBase64() {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(this);
  }
}

extension ConvertStringToDateTime on String {
  String convertStringToDateTime() {
    int ts = int.parse(this);
    var dt = DateTime.fromMillisecondsSinceEpoch(ts);

    var date = DateFormat('yyyy-dd-MM').format(dt);
    console(date);
    return date;
  }

  String convertStringDDMMYYYHHMMSSDateToEMMMDDYYYY() {
    final inputFormat = DateFormat("yyyy-MM-dd'T'hh:mm:ss");
    final parsedDate = inputFormat.parse(this);
    final outputFormat = DateFormat('dd-MM-yyyy', 'en_US');
    final formattedDate = outputFormat.format(parsedDate);
    return formattedDate;
  }
}
