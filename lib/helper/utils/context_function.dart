import 'package:flutter/material.dart';

extension CustomDialog on BuildContext {
  double fullWidth({double multiplier = 1.0}) {
    return MediaQuery.of(this).size.width * multiplier;
  }

  double fullHeight({double multiplier = 1.0}) {
    return MediaQuery.of(this).size.height * multiplier;
  }


}
