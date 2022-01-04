import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:listly/models/items/notes.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/screens/item/notes/controller/notes_controller.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';
import 'package:get/get.dart';

createItemDialog(ListModel listModel, {Note? item}) {
  NotesController itemController = Get.find();
  itemController.item = item;
  Get.bottomSheet(Container(
    padding: EdgeInsets.all(20.0.w),
    color: Colors.white,
    child: Builder(builder: (context) {
      return SingleChildScrollView(
        child: Form(
          key: itemController.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10.h,
              ),
              MyTextField(
                labelText: 'Item Title',
                controller: itemController.titleController,
                validator: itemController.validateTitle,
              ),
              SizedBox(
                height: 20.h,
              ),
              MyTextField(
                textInputType: TextInputType.multiline,
                expanded: true,
                labelText: 'Item Description',
                controller: itemController.descriptionController,
              ),
              SizedBox(
                height: 20.h,
              ),
              Obx(() {
                return MyButton(
                  onPressed: () async {
                    await itemController.createItem(listModel);
                  },
                  buttonText: item != null ? 'Update Note' : 'Add Note',
                  isLoading: itemController.isLoading.value,
                );
              }),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        ),
      );
    }),
  ));
}
