

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:listly/models/items/todo_item.dart';
import 'package:share/share.dart';

import 'create_pdf.dart';

shareDataDialog(List<TodoItem>? items, String title,String  listId) {
  if (items == null) {
    return;
  }
  Get.bottomSheet(Container(
      margin: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20.h,
          ),
          InkWell(
            onTap: () {
              Get.back();
              createPdf(items, title, listId);
            },
            child: SizedBox(
              width: double.infinity,
              height: 40.h,
              child: Text(
                'Create Pdf',
                style: Theme.of(Get.context!).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.h),
            width: double.infinity,
            height: 1,
            color: Colors.grey.shade300,
          ),
          SizedBox(
            height: 10.h,
          ),
          InkWell(
            onTap: () async {
              String message = title + '\n\n';
              for (TodoItem item in items) {
                message +=
                '${item.isDone?'Done':'Pending'} : ${item.title} \n';
              }
              Get.back();
              await Share.share(message);
            },
            child: SizedBox(
              width: double.infinity,
              height: 40.h,
              child: Text(
                'Share as Message',
                style: Theme.of(Get.context!).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          )
        ],
      )));
}

