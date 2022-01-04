import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:listly/utils/theme/color_palette.dart';
showLoading(String title) {
  Get.dialog(Dialog(
    child: Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        children: [
          CircularProgressIndicator(
            color: ColorPalette.yellow,
          ),
          SizedBox(
            width: 20.w,
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(Get.context!).textTheme.headline4,
            ),
          )
        ],
      ),
    ),
  ));
}