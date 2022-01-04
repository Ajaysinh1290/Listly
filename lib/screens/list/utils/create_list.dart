import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/screens/list/controller/list_controller.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';

createList({ListModel? listModel}) {

  ListController listController = Get.find();
  listController.titleController.text = '';
  listController.listModel = listModel;


  Get.bottomSheet(Container(
    padding: EdgeInsets.all(20.0.w),
    color: Colors.white,
    child: SingleChildScrollView(
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
          Opacity(
            opacity: listModel == null ? 1 : 0.5,
            child: AbsorbPointer(
              absorbing: listModel != null,
              child: Container(
                padding: EdgeInsets.all(8.0.sp),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black.withOpacity(0.1), width: 1.2),
                    borderRadius: BorderRadius.circular(4)),
                child: Obx(() {
                  return DropdownButton(
                      value: listController.listType,
                      onChanged: (value) {
                        listController.listType = value.toString();
                      },
                      underline: Container(),
                      isExpanded: true,
                      items: Constants.listTypes
                          .map(
                            (value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value,
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                          fontFamily:
                                              GoogleFonts.roboto().fontFamily,
                                          fontWeight: FontWeight.normal),
                                )),
                          )
                          .toList());
                }),
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Obx(() {
            return MyButton(
              onPressed: () async {
                await listController.createList();
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
    ),
  ));
}
