import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listly/utils/theme/color_palette.dart';

mixin AppThemeData {
  get appThemeData => ThemeData(
      backgroundColor: Colors.white,
      primaryColor: ColorPalette.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
          toolbarHeight: 80.h,
          color: Colors.white,
          elevation: 2,
          centerTitle: true,
          shadowColor: Colors.black.withOpacity(0.2),
          titleTextStyle: GoogleFonts.notoSerif(
              color: Colors.black,
              fontSize: 22.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2),
          iconTheme: const IconThemeData(color: Colors.black)),
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: TextTheme(
        caption: GoogleFonts.poppins(
            fontSize: 11.sp, letterSpacing: 1.2, fontWeight: FontWeight.w500),
        bodyText1: GoogleFonts.poppins(
            color: Colors.black,
            letterSpacing: 1.2,
            fontSize: 22.sp,
            fontWeight: FontWeight.w600),
        bodyText2: GoogleFonts.poppins(
            color: Colors.black,
            letterSpacing: 1.2,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500),
        headline1: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 32.sp,
            letterSpacing: 1.2,
            color: Colors.black),
        headline2: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 28.sp,
            letterSpacing: 1.2,
            color: Colors.black),
        headline3: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
            letterSpacing: 1.2,
            color: Colors.black),
        headline4: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 20.sp,
            letterSpacing: 1.2,
            color: Colors.black),
        headline5: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            letterSpacing: 1.2,
            color: Colors.black),
        headline6: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18.sp,
            letterSpacing: 1.2,
            color: Colors.black),
      ));
}
