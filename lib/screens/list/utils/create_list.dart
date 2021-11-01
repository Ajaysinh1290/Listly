import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:listly/models/list_model.dart';
import 'package:listly/screens/list/controller/list_controller.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';


createList({ListModel? listModel}) {
  ListController listController = Get.find();
  listController.titleController.text = '';
  listController.listModel = listModel;
  Get.bottomSheet(Container(
    padding: EdgeInsets.all(20.0.w),
    color: Colors.white,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 10.h,
        ),
        MyTextField(
          labelText: 'List Title',
          controller: listController.titleController,
        ),
        SizedBox(
          height: 20.h,
        ),
        Obx(() {
          return MyButton(
            onPressed: () async {
              await listController.createTitle();
              Get.back();
            },
            buttonText: listModel == null ? 'Create' : 'Update',
            isLoading: listController.isLoading.value,
          );
        }),
        SizedBox(
          height: 10.h,
        ),
      ],
    ),
  ));
}
