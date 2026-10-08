import 'package:flutter/material.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    Key? key,
    required String text,
    required Color textColor,
    required Color buttonColor,
    required FontWeight textFontWeight,
    required double fontSize,
    required VoidCallback onPressed,
    required double elevation,
    bool isBordered = false,
  })  : _text = text,
        _textColor = textColor,
        _textFontWeight = textFontWeight,
        _fontSize = fontSize,
        _onPressed = onPressed,
        _buttonColor = buttonColor,
        _elevation = elevation,
        _isBordered = isBordered,
        super(key: key);

  final String _text;
  final Color _textColor;
  final Color _buttonColor;
  final FontWeight _textFontWeight;
  final double _fontSize;
  final VoidCallback _onPressed;
  final double _elevation;
  final bool _isBordered;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: _buttonColor,
            side: _isBordered
                ? BorderSide(
                    width: 1.0,
                    color: borderColor,
                  )
                : null,
            onPrimary: Colors.white,
            shadowColor: textColorLight,
            elevation: _elevation,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
          onPressed: _onPressed,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: TextView(
                text: _text,
                textColor: _textColor,
                textFontWeight: _textFontWeight,
                fontSize: _fontSize),
          )),
    );
  }
}
