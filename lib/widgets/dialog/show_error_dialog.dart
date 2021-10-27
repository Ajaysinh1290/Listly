import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:listly/utils/theme/color_palette.dart';

showErrorDialog(String title, String subTitle) {
  Get.bottomSheet(
    Builder(builder: (context) {
      return Padding(
        padding: EdgeInsets.all(20.0.w),
        child: Material(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0.w),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Icon(
                        Icons.warning,
                        size: 70.w,
                        color: ColorPalette.yellow,
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      subTitle,
                      style: Theme.of(context).textTheme.subtitle1,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Container(
                      width: double.infinity,
                      height: 2,
                      color: Theme.of(context).cardColor,
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 20.h),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          'TRY AGAIN',
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }),
  );
  // Get.defaultDialog(
  //   backgroundColor: Colors.white,
  //   radius: 0,
  //   title: '',
  //   contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  //   titlePadding: EdgeInsets.zero,
  //   content: Builder(builder: (context) {
  //     return SizedBox(
  //       width: MediaQuery.of(context).size.width,
  //       child: Column(
  //         children: [
  //           Center(
  //             child: Icon(
  //               Icons.warning,
  //               size: 70.w,
  //               color: Colors.red,
  //             ),
  //           ),
  //           SizedBox(
  //             height: 15.h,
  //           ),
  //           Text(
  //             title,
  //             style: Theme.of(context).textTheme.headline2,
  //             textAlign: TextAlign.center,
  //           ),
  //           SizedBox(
  //             height: 10.h,
  //           ),
  //           Text(
  //             subTitle,
  //             style: Theme.of(context).textTheme.subtitle1,
  //             textAlign: TextAlign.center,
  //           ),
  //           SizedBox(
  //             height: 30.h,
  //           ),
  //           Container(
  //             width: double.infinity,
  //             height: 2,
  //             color: Theme.of(context).cardColor,
  //           ),
  //           SizedBox(
  //             height: 30.h,
  //           ),
  //           GestureDetector(
  //             onTap: () {
  //               Get.back();
  //             },
  //             child: Container(
  //               padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.h),
  //               decoration: BoxDecoration(
  //                   color: Theme.of(context).primaryColor,
  //                   borderRadius: BorderRadius.circular(5)),
  //               child: Text(
  //                 'TRY AGAIN',
  //                 style: Theme.of(context)
  //                     .textTheme
  //                     .headline6!
  //                     .copyWith(color: Colors.white),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     );
  //   }),
  // );
}
