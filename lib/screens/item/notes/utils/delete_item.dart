import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/items/notes.dart';
import 'package:listly/models/list_model.dart';
import 'package:get/get.dart';
import 'package:listly/screens/item/notes/controller/notes_controller.dart';
import 'package:listly/utils/theme/color_palette.dart';

void onDeleteItem(Note item, ListModel listModel) async {
  FirebaseFirestore.instance
      .collection('users')
      .doc(Get.find<UserController>().user!.userId)
      .collection('lists')
      .doc(listModel.listId)
      .collection('items')
      .doc(item.itemId)
      .delete();
  NotesController itemController = Get.find();
  itemController.list!.remove(item);
  itemController.refreshDataOnScreen();
  int itemIndex = listModel.items!.indexOf(item.itemId);
  listModel.items!.remove(item.itemId);
  FirebaseFirestore.instance
      .collection('users')
      .doc(Get.find<UserController>().user!.userId)
      .collection('lists')
      .doc(listModel.listId)
      .set(listModel.toJson());
  bool isUndoButtonPressed = false;
  Get.showSnackbar(GetBar(
    backgroundColor: ColorPalette.yellow,
    duration: const Duration(seconds: 2),
    message: "Item Deleted Successfully",
    mainButton: TextButton(
      onPressed: () async {
        if (!isUndoButtonPressed) {
          isUndoButtonPressed = true;
          Get.back();
          NotesController itemController = Get.find();
          itemController.list!.insert(itemIndex, item);
          itemController.refreshDataOnScreen();
          FirebaseFirestore.instance
              .collection('users')
              .doc(Get.find<UserController>().user!.userId)
              .collection('lists')
              .doc(listModel.listId)
              .collection('items')
              .doc(item.itemId)
              .set(item.toJson());
          listModel.items?.insert(itemIndex, item.itemId);
          FirebaseFirestore.instance
              .collection('users')
              .doc(Get.find<UserController>().user!.userId)
              .collection('lists')
              .doc(listModel.listId)
              .set(listModel.toJson());
        }
      },
      child: Text(
        'UNDO',
        style: Theme.of(Get.context!).textTheme.headline6!.copyWith(
            fontWeight: FontWeight.w900,
            color: ColorPalette.blue,
            fontSize: 16.sp),
      ),
    ),
  ));
}
