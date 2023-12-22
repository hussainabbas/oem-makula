import 'package:flutter/material.dart';
import 'package:makula_oem/helper/utils/colors.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isValid,
    Color? backgroundColor,
    //bool? isFullRounded = false,
    this.textColor,
    this.heightMultiplier,
    this.fontFamily,
    this.iconData,
    this.borderRadius,
    this.fontSize,
    bool? isContainIcon = false,
    double? widthMultiplier = 0.7,
  })  : _backgroundColor = backgroundColor,

        _isContainIcon = isContainIcon,
        _widthMultiplier = widthMultiplier;

  final String title;
  final VoidCallback onPressed;
  final Color? _backgroundColor;
  //final bool? _isFullRounded;
  final double? borderRadius;
  final Color? textColor;
  final bool? _isContainIcon;
  final bool? isValid;
  final double? _widthMultiplier;
  final double? heightMultiplier;
  final double? fontSize;
  final String? fontFamily;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (_widthMultiplier ?? 0.7),
        height: heightMultiplier ?? 44,
        child: ElevatedButton(
          onPressed: isValid ?? true ? onPressed : null,

          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 0), // Set the corner radius here
              ),
              foregroundColor: Colors.white,
              backgroundColor:
                  _backgroundColor ?? primaryColor // Set the background color here
              ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0 , 8, 0 , 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image.asset(
                //   'assets/google_logo.png', // Replace with your image asset path
                //   height: 24,
                //   width: 24,
                // ),
                if (_isContainIcon ?? false)
                  Icon(iconData ?? Icons.social_distance_outlined, color: Colors.white,size: 16),
                // Add some spacing between image and text
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: fontFamily ?? "Roboto",
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize ?? 16,
                    ),
                  ),
                //     child: TextView(
                //   text: title,
                //   textColor: Colors.white,
                //   textFontWeight: FontWeight.bold,
                //   fontSize: 16,
                //   align: TextAlign.center,
                // )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
