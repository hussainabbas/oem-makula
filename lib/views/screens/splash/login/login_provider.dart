import 'package:flutter/cupertino.dart';

class LoginProvider with ChangeNotifier {
  bool _emailValidation = false;
  bool _passwordValidation = false;

  String _emailErrorText = "";
  String _passwordErrorText = "";

  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  bool get emailValidation => _emailValidation;

  bool get passwordValidation => _passwordValidation;

  bool get isPasswordFocused => _isPasswordFocused;

  bool get isEmailFocused => _isEmailFocused;

  String get passwordErrorText => _passwordErrorText;

  String get emailErrorText => _emailErrorText;

  void setEmailValidation(bool isValidated) {
    _emailValidation = isValidated;
    notifyListeners();
  }

  void setPasswordValidation(bool isValidated) {
    _passwordValidation = isValidated;
    notifyListeners();
  }

  void setIsEmailFocused(bool isValidated) {
    _isEmailFocused = isValidated;
    notifyListeners();
  }

  void setIsPasswordFocused(bool isValidated) {
    _isPasswordFocused = isValidated;
    notifyListeners();
  }

  void setEmailError(String error) {
    _emailErrorText = error;
    notifyListeners();
  }

  void setPasswordError(String error) {
    _passwordErrorText = error;
    notifyListeners();
  }
}
