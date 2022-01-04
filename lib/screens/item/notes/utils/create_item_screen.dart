import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:listly/models/items/notes.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/screens/item/notes/controller/notes_controller.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';

import 'delete_item.dart';

class CreateItemScreen extends StatelessWidget {
  final ListModel listModel;
  final Note? item;

  const CreateItemScreen(this.listModel, {Key? key, this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    NotesController itemController = Get.find();
    if(item!=null) {
      itemController.item = item;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note"),
        actions: [
          if (item != null)
            IconButton(
              icon: const Icon(Icons.delete,size: 20,color: Colors.red,),
              onPressed: () {
                Get.back();
                onDeleteItem(item!,listModel);
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: Constants.scaffoldPadding,
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
                  minLines: 5,
                  hintText: 'Item Description',
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
        ),
      ),
    );
  }
}
