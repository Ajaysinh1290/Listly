
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:listly/models/items/todo_item.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/screens/item/todo/controller/todo_item_controller.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';
import 'package:get/get.dart';

createItemDialog(ListModel listModel, {TodoItem? item}) {
  TodoItemsController itemController = Get.find();
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
              Obx(() {
                return MyButton(
                  onPressed: () async {
                    await itemController.createItem(listModel);
                  },
                  buttonText: item != null ? 'Update Item' : 'Add Item',
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
