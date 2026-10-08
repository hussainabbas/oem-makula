import 'package:flutter/cupertino.dart';

class TextView extends StatelessWidget {
  const TextView(
      {Key? key,
      required String text,
      required Color textColor,
      required FontWeight textFontWeight,
      required double fontSize,
      bool isEllipsis = false,
      TextAlign? align})
      : _text = text,
        _textColor = textColor,
        _textFontWeight = textFontWeight,
        _fontSize = fontSize,
        _align = align,
        _isEllipsis = isEllipsis,
        super(key: key);

  final String _text;
  final Color _textColor;
  final FontWeight _textFontWeight;
  final double _fontSize;
  final TextAlign? _align;
  final bool _isEllipsis;

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      overflow: _isEllipsis ? TextOverflow.ellipsis : null,
      softWrap: true,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: _fontSize,
        color: _textColor,
        fontWeight: _textFontWeight,
        height: 1.4,
      ),
      textHeightBehavior:
          const TextHeightBehavior(applyHeightToFirstAscent: false),
      textAlign: _align ?? TextAlign.start,
    );
  }
}
