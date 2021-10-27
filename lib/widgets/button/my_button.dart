import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listly/utils/theme/color_palette.dart';

class MyButton extends StatelessWidget {
  final Function()? onPressed;
  final String buttonText;
  final bool? isLoading;
  final Color? buttonColor;
  final Color? buttonTextColor;

  const MyButton(
      {Key? key,
      required this.onPressed,
      required this.buttonText,
      this.isLoading,
      this.buttonColor,
      this.buttonTextColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ?? false ? null : onPressed,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 70.w,
        decoration: BoxDecoration(
          color: buttonColor ?? Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: isLoading ?? false
            ? SizedBox(
                width: 25.w,
                height: 25.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  backgroundColor: Colors.white54,
                  valueColor: AlwaysStoppedAnimation(ColorPalette.yellow),
                ))
            : Text(
                buttonText,
                style: Theme.of(context).textTheme.headline4!.copyWith(
                    color: buttonTextColor ?? Colors.white,
                    fontSize: 22.sp,
                    fontFamily: GoogleFonts.notoSerif().fontFamily),
              ),
      ),
    );
  }
}
