import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';

extension Keyboard on BuildContext {
  void hideKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}

extension Validation on String {
  bool isValidated() {
    if (isEmpty) {
      return true;
    } else {
      return false;
    }
  }
}

extension CustomDialog on BuildContext {
  void showCustomDialog() {
    showGeneralDialog(
      context: this,
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
      /*transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },*/
    );
  }
}

void console(String message) {
  if (kDebugMode) {
    log(message);
  }
}

Color getContainerBgColor(String status) {
  if (status == "closed") {
    return closedContainerColor;
  } else {
    return visitContainerColor;
  }
}

String getFileExtension(String fileName) {
  var type = fileName.split('.').last;
  if (type.contains("jpg")) {
    return "image/jpg";
  } else if (type.contains("jpeg")) {
    return "image/jpeg";
  } else if (type.contains("png")) {
    return "image/png";
  } else if (type.contains("docx")) {
    return "document/docx";
  } else if (type.contains("txt")) {
    return "document/txt";
  } else if (type.contains("pdf")) {
    return "document/pdf";
  } else {
    return "." + fileName.split('.').last;
  }
}

Color getContainerFrontColor(String status) {
  if (status == "closed") {
    return closedStatusColor;
  } else {
    return visitStatusColor;
  }
}

Color getContainerFrontColor2(String status) {
  if (status == "closed") {
    return closedContainerColor;
  } else {
    return visitContainerColor;
  }
}


Color getStatusContainerColor(String status) {
  if (status == "open") {
    return redContainerColor;
  } else if (status == "on hold" || status == "hold") {
    return onHoldContainerColor;
  } else if (status == "visit planned" || status == "visit") {
    return visitContainerColor;
  } else if (status == "waiting input" || status == "waiting") {
    return waitingContainerColor;
  } else if (status == "closed") {
    return closedContainerColor;
  } else if (status == "callback scheduled" || status == "callback") {
    return callbackContainerColor;
  } else {
    return redContainerColor;
  }
}

Color getStatusColor(String status) {
  ////print"status = $status");
  if (status == "open") {
    return redStatusColor;
  } else if (status == "on hold" || status == "hold") {
    return onHoldStatusColor;
  } else if (status == "visit planned" || status == "visit") {
    return visitStatusColor;
  } else if (status == "waiting input" || status == "waiting") {
    return waitingStatusColor;
  } else if (status == "closed") {
    return closedStatusColor;
  } else if (status == "callback scheduled" || status == "callback") {
    return callbackStatusColor;
  } else {
    return redStatusColor;
  }
}

Color getIconColor(String status) {
  ////print"status = $status");
  if (status == "open") {
    return visitStatusColor;
  } else {
    return textColorLight;
  }
}

String ticketID(String ticketId) {
  if (ticketId.isNotEmpty) {
    return ticketId;
  } else {
    return ticketLabel;
  }
}

String checkAssignee(String assignee) {
  if (assignee.isNotEmpty) {
    return assignee;
  } else {
    return notYetAssigned;
  }
}

Widget noTicketWidget(BuildContext context, String message) {
  return Container(
    margin: const EdgeInsets.fromLTRB(0, 32, 0, 16),
    width: MediaQuery.of(context).size.width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset("assets/images/No Ticket Assigned.svg"),
        Text(
          message,
          style: TextStyle(
              fontSize: 14, fontFamily: 'Manrope', color: textColorLight),
        )
      ],
    ),
  );
}

Widget noMachineWidget(BuildContext context, String message) {
  return Container(
    margin: const EdgeInsets.fromLTRB(0, 32, 0, 16),
    width: MediaQuery.of(context).size.width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset("assets/images/no_machine_history.svg"),
        Text(
          message,
          style: TextStyle(
              fontSize: 14, fontFamily: 'Manrope', color: textColorLight),
        )
      ],
    ),
  );
}

Widget noMachineDocumentationWidget(BuildContext context, String message) {
  return Container(
    margin: const EdgeInsets.fromLTRB(0, 32, 0, 16),
    width: MediaQuery.of(context).size.width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset("assets/images/no_machine_documentation.svg"),
        const SizedBox(
          height: 16,
        ),
        Text(
          message,
          style: TextStyle(
              fontSize: 14,
              fontFamily: 'Manrope',
              color: textColorLight,
              fontWeight: FontWeight.w500),
        )
      ],
    ),
  );
}

String? parseHtmlString(String htmlString) {
  //final document = parse(htmlString);
  //final String? parsedString = parse(document.body?.text).documentElement?.text;
  return htmlString
      .replaceAll("<p>", "") // Paragraphs
      .replaceAll("<br />", "")
      .replaceAll("\n\n", "")
      .replaceAll("<span>", "")
      .replaceAll("</span>", "")
      .replaceAll("  ", " ") // Line Breaks
      .replaceAll("   ", " ") // Line Breaks
      .replaceAll("    ", "") // Line Breaks
      .replaceAll("     ", "") // Line Breaks
      .replaceAll("      ", "") // Line Breaks
      .replaceAll("<strong>", "") // Line Breaks
      .replaceAll("</strong>", "") // Line Breaks
      .trim();
  //return parsedString;
}

bool isFileImage(String fileName) {
  if (fileName.contains(".jpg") ||
      fileName.contains(".png") ||
      fileName.contains(".jpeg")) {
    return true;
  } else {
    return false;
  }
}

showLoaderDialog(BuildContext context, String message) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator.adaptive(),
        const SizedBox(
          width: 8,
        ),
        Container(margin: const EdgeInsets.only(left: 7), child: Text(message)),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

String setAuthOnFile(String uuid, String auth, String file) {
  //print"setAuthOnFile => $file&uuid=$uuid&auth=$auth");
  return "$file&uuid=$uuid&auth=$auth";
}

getFormattedDate(String dateTimeStamp, String format) {
  var dateEpoch = int.parse(dateTimeStamp) / 10000;
  var date =
      DateTime.fromMillisecondsSinceEpoch(dateEpoch.toInt(), isUtc: false);
  var d12 = DateFormat(format).format(date);
  return d12;
}

String getInitials(String name) {
  var nameArray = name.toString().split(" ");
  var firstLetter = "";
  var secondLetter = "";
  if (nameArray.length > 1) {
    var firstName = nameArray[0];
    var lastName = nameArray[1];

    firstLetter = firstName.substring(0, 1);
    secondLetter = lastName.substring(0, 1);
  } else {
    var firstName = nameArray[0];
    firstLetter = firstName.substring(0, 1);
    secondLetter = firstName.substring(1, 2);
  }

  return firstLetter + secondLetter;
}

double getFileSize(File file) {
  int sizeInBytes = file.lengthSync();
  double sizeInMb = sizeInBytes / (1024 * 1024);
  //print"getFileSize => $sizeInMb");
  return sizeInMb;
}

String getFileSizeInBytes(File file) {
  int sizeInBytes = file.lengthSync();
  return sizeInBytes.toString();
}

Widget line(BuildContext context) {
  return SvgPicture.string(
    '<svg viewBox="20.0 133.0 335.0 1.0" ><path transform="translate(20.0, 133.0)" d="M 0 1 L 230.4658050537109 1 L 335 1 L 335 0 L 0 0 L 0 1 Z" fill="#E6E8FE" stroke="none" stroke-width="1" stroke-miterlimit="10" stroke-linecap="butt" /></svg>',
    allowDrawingOutsideViewBox: true,
    fit: BoxFit.fill,
    width: MediaQuery.of(context).size.width,
  );
}

Widget defaultImage() {
  return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: darkGrey,
        child: Image.asset(
          "assets/images/default_image.png",
          width: 56,
          height: 56,
        ),
      ));
}

Widget defaultImageBig(BuildContext context) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.asset(
        "assets/images/default_image.png",
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width,
        height: 200,
      ));
}

Uint8List decodeBase64(String base64) {
  var image = base64
      .replaceAll("data:image/jpeg;base64,", "")
      .replaceAll("data:image/png;base64,", "")
      .replaceAll("data:image/jpg;base64,", "");
  return const Base64Codec().decode(image);
}