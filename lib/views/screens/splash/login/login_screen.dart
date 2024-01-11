import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';
import 'package:makula_oem/helper/model/login_mobile_oem_response.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/login_view_model.dart';
import 'package:makula_oem/main.dart';
import 'package:makula_oem/views/screens/splash/login/login_provider.dart';
import 'package:makula_oem/views/widgets/makula_button.dart';
import 'package:makula_oem/views/widgets/makula_edit_text.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';

final TextEditingController _emailController =
    // TextEditingController(text: "azfar.rashid@mmmtechltd.com");
    TextEditingController();
final TextEditingController _passwordController =
    // TextEditingController(text: "RyCJxRdy0u");
    TextEditingController();
final FocusNode _emailFieldFocus = FocusNode();
final FocusNode _passwordFieldFocus = FocusNode();
late BuildContext _context;
final appPreferences = AppPreferences();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    _addEditTextListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context.hideKeyboard();
          },
          child: _loginScreenContent()),
    );
  }
}

Widget _loginScreenContent() {
  return Stack(
    alignment: Alignment.topCenter,
    children: [
      Image.asset("assets/images/bg_splash_png.png",
          height: MediaQuery.of(_context).size.height,
          width: MediaQuery.of(_context).size.width,
          fit: BoxFit.fill),
      Image.asset(
        "assets/images/Combined-Shape2.png",
        fit: BoxFit.fill,
        width: MediaQuery.of(_context).size.width,
      ),
      Container(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 48,
            ),
            SvgPicture.asset("assets/images/Makula_Logo_White.svg"),
            const SizedBox(
              height: 32,
            ),
            Expanded(
                child: Container(
                    width: MediaQuery.of(_context).size.width,
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        //new Color.fromRGBO(255, 0, 0, 0.0),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        )),
                    child: CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                            hasScrollBody: false,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 24,
                                ),
                                TextView(
                                    text: welcome,
                                    textColor: textColorDark,
                                    textFontWeight: FontWeight.w700,
                                    fontSize: 20),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextView(
                                    text: pleaseEnterYourCredentials,
                                    textColor: textColorLight,
                                    textFontWeight: FontWeight.w500,
                                    fontSize: 13),
                                const SizedBox(
                                  height: 50,
                                ),
                                Expanded(child: _formWidgets()),
                                // EMAIL AND PASSWORD FORM FIELDS
                                const SizedBox(
                                  height: 16,
                                ),
                                MyButton(
                                    text: signInLabel,
                                    textColor: Colors.white,
                                    textFontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    buttonColor: primaryColor,
                                    elevation: 10,
                                    onPressed: () {
                                      _signIn();
                                    }),
                              ],
                            )),
                      ],
                    ))),
          ],
        ),
      )
    ],
  );
}

Widget _formWidgets() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextView(
          text: emailLabel,
          textColor: textColorLight,
          textFontWeight: FontWeight.w500,
          fontSize: 13),
      const SizedBox(
        height: 10,
      ),
      EditText(
          hintText: hintEmailText,
          textColor: textColorLight,
          containerColor: _context.watch<LoginProvider>().isEmailFocused
              ? Colors.white
              : containerColorUnFocused,
          textFontWeight: FontWeight.w500,
          fontSize: 14,
          controller: _emailController,
          focusNode: _emailFieldFocus,
          isValidate: _context.watch<LoginProvider>().emailValidation,
          validateError: _context.watch<LoginProvider>().emailErrorText),
      const SizedBox(
        height: 24,
      ),
      TextView(
          text: passwordLabel,
          textColor: textColorLight,
          textFontWeight: FontWeight.w500,
          fontSize: 13),
      const SizedBox(
        height: 10,
      ),
      EditText(
          hintText: hintPasswordText,
          textColor: textColorLight,
          containerColor: _context.watch<LoginProvider>().isPasswordFocused
              ? Colors.white
              : containerColorUnFocused,
          textFontWeight: FontWeight.w500,
          fontSize: 14,
          isObscureText: true,
          isBigEditText: false,
          controller: _passwordController,
          focusNode: _passwordFieldFocus,
          isValidate: _context.watch<LoginProvider>().passwordValidation,
          validateError: _context.watch<LoginProvider>().passwordErrorText)
    ],
  );
}

void _signIn() async {
  var email = _emailController.text.toString();
  var password = _passwordController.text.toString();

  if (email.isEmpty) {
    _context.read<LoginProvider>().setEmailValidation(true);
    _context.read<LoginProvider>().setEmailError(emailErrorText);
  }

  if (password.isEmpty) {
    _context.read<LoginProvider>().setPasswordValidation(true);
    _context.read<LoginProvider>().setPasswordError(passwordErrorText);
  }

  if (email.isNotEmpty && password.isNotEmpty) {
    _context.read<LoginProvider>().setPasswordValidation(false);
    _context.read<LoginProvider>().setEmailValidation(false);

    _context.showCustomDialog();
    console("LoginViewModel");
    var result =
        await LoginViewModel().login(email, password.convertStringToBase64());
    result.join(
        (failed) => {
              Navigator.pop(_context),
              if (failed.exception == noUserError)
                {
                  _context.read<LoginProvider>().setEmailValidation(true),
                  _context.read<LoginProvider>().setEmailError(noUserError)
                },
              if (failed.exception == wrongPasswordError)
                {
                  _context.read<LoginProvider>().setPasswordValidation(true),
                  _context
                      .read<LoginProvider>()
                      .setPasswordError(wrongPasswordError)
                },
              console("failed => " + failed.exception.toString())
            },
        (loaded) => {
              _saveUserToken(loaded.data),
            },
        (loading) => {console("loading => ")});

    // Navigator.pop(_context);
  }
}

_saveUserToken(LoginMobile data) async {
  console("_saveUserToken");
  // HiveResources.loginBox?.put(OfflineResources.LOGIN_TOKEN_RESPONSE, data);
  //appPreferences.setString(AppPreferences.TOKEN, data.token.toString());
  // appPreferences.setString(
  //   AppPreferences.REFRESH_TOKEN, data.refreshToken.toString());
  //appPreferences.setBool(AppPreferences.LOGGED_IN, true);

  appDatabase?.loginMobileDao.insertLoginMobileOemIntoDb(data);
  GraphQLConfig.token = data.token.toString();
  GraphQLConfig.refreshToken = data.refreshToken.toString();
  _getCurrentUserDetails();
}

_getCurrentUserDetails() async {
  console("_getCurrentUserDetails");
  var result = await LoginViewModel().getCurrentUserDetails();
  result.join(
      (failed) =>
          {Navigator.pop(_context), console("failed => ${failed.exception}")},
      (loaded) => {
            console("_getCurrentUserDetails => ${loaded.data}"),
            Navigator.pop(_context),
            _saveUserDetailsInAppPreferences(loaded.data),
          },
      (loading) => {
            console("loading => "),
          });
}

_saveUserDetailsInAppPreferences(CurrentUser data) async {
  // HiveResources.currentUserBox?.put(OfflineResources.CURRENT_USER_RESPONSE, data);
  //await appPreferences.setData(AppPreferences.USER, data);
  appDatabase?.userDao.insertCurrentUserDetailsIntoDb(data);
  _getOEMStatues();
  // if (_context.mounted) {
  //   Navigator.of(_context).pushNamedAndRemoveUntil(
  //       dashboardScreenRoute, (Route<dynamic> route) => false);
  // }
}

_getOEMStatues() async {
  try {
    var result = await LoginViewModel().getOEMStatuses();
    result.join(
        (failed) => {
              Navigator.pushReplacementNamed(_context, loginScreenRoute),
              console("failed => ${failed.exception}")
            },
        (loaded) => {
              // console("loaded => " + loaded.data)
              _saveOEMStatues(loaded.data)
            },
        (loading) => {
              console("loading => "),
            });
  } catch (e) {
    console("_getOEMStatues = $e");
    if (_context.mounted)
      Navigator.pushReplacementNamed(_context, loginScreenRoute);
  }
}

_saveOEMStatues(StatusData response) async {
  console("_saveOEMStatues => ${response.listOwnOemOpenTickets?.length}");
  // HiveResources.oemStatusBox?.put(OfflineResources.OEM_STATUS_RESPONSE, response);
  //await appPreferences.setData(AppPreferences.STATUES, response);
  appDatabase?.oemStatusDao.insertGetOemStatusesResponse(response);
  if (_context.mounted) {
    Navigator.of(_context).pushNamedAndRemoveUntil(
        dashboardScreenRoute, (Route<dynamic> route) => false);
  }
}

_addEditTextListeners() {
  _emailFieldFocus.addListener(() {
    if (_emailFieldFocus.hasFocus) {
      _context.read<LoginProvider>().setIsEmailFocused(true);
    } else {
      if (_emailController.text.isNotEmpty) {
        _context.read<LoginProvider>().setIsEmailFocused(true);
      } else {
        _context.read<LoginProvider>().setIsEmailFocused(false);
      }
    }
  });

  _passwordFieldFocus.addListener(() {
    if (_passwordFieldFocus.hasFocus) {
      _context.read<LoginProvider>().setIsPasswordFocused(true);
    } else {
      if (_passwordController.text.isNotEmpty) {
        _context.read<LoginProvider>().setIsPasswordFocused(true);
      } else {
        _context.read<LoginProvider>().setIsPasswordFocused(false);
      }
    }
  });
}
