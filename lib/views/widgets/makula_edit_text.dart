import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';

class EditText extends StatelessWidget {
  const EditText(
      {Key? key,
      required String hintText,
      required Color textColor,
      required Color containerColor,
      required FontWeight textFontWeight,
      required double fontSize,
      required TextEditingController controller,
      required FocusNode focusNode,
      required bool isValidate,
      required String validateError,
      bool isBigEditText = false,
      bool isObscureText = false})
      : _controller = controller,
        _hintText = hintText,
        _focusNode = focusNode,
        _textColor = textColor,
        _textFontWeight = textFontWeight,
        _fontSize = fontSize,
        _isValidate = isValidate,
        _validateError = validateError,
        _containerColor = containerColor,
        _isBigEditText = isBigEditText,
        _obscureText = isObscureText,
        super(key: key);

  final TextEditingController _controller;
  final FocusNode _focusNode;
  final String _hintText;
  final Color _textColor;
  final Color _containerColor;
  final FontWeight _textFontWeight;
  final bool _isValidate;
  final double _fontSize;
  final String _validateError;
  final bool _isBigEditText;
  final bool _obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: containerColorUnFocused,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: _isValidate ? redBorderColor : borderColor,
              width: 1,
            ),
          ),
          child: TextFormField(
            obscureText: _obscureText,
            keyboardType:
                _isBigEditText ? TextInputType.multiline : TextInputType.text,
            maxLines: _isBigEditText ? 6 : 1,
            controller: _controller,
            autocorrect: false,
            focusNode: _focusNode,
            style: TextStyle(
                fontFamily: "Manrope",
                fontSize: _fontSize,
                color: _textColor,
                fontWeight: _textFontWeight),
            decoration: InputDecoration(
              fillColor: _containerColor,
              filled: true,
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: redBorderColor),
              ),
              hintStyle: TextStyle(
                  fontFamily: "Manrope",
                  fontSize: _fontSize,
                  color: textColorLight,
                  fontWeight: _textFontWeight),
              hintText: _hintText,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
        _isValidate
            ? Container(
                margin: const EdgeInsets.only(top: 6),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SvgPicture.asset("assets/images/errors.svg"),
                    const SizedBox(
                      width: 4,
                    ),
                    TextView(
                        text: _validateError,
                        textColor: redBorderColor,
                        textFontWeight: FontWeight.w500,
                        fontSize: 12)
                  ],
                ),
              )
            : Container(),
      ],
    );
  }
}
