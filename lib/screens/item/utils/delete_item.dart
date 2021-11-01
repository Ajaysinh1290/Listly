import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/item.dart';
import 'package:listly/models/list_model.dart';
import 'package:get/get.dart';
import 'package:listly/utils/theme/color_palette.dart';

void onDeleteItem(Item item, ListModel listModel) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(Get.find<UserController>().user!.userId)
      .collection('lists')
      .doc(listModel.listId)
      .collection('items')
      .doc(item.itemId)
      .delete();
  int itemIndex = listModel.items!.indexOf(item.itemId);
  listModel.items!.remove(item.itemId);
  await FirebaseFirestore.instance
      .collection('users')
      .doc(Get.find<UserController>().user!.userId)
      .collection('lists')
      .doc(listModel.listId)
      .set(listModel.toJson());
  bool isUndoButtonPressed = false;
  Get.snackbar(
    '',
    '',
    animationDuration: const Duration(milliseconds: 500),
    titleText: Text(
      'Item Deleted Successfully',
      style: Theme.of(Get.context!)
          .textTheme
          .headline6!
          .copyWith(fontWeight: FontWeight.bold),
    ),
    messageText: Text(
      item.title,
      style: Theme.of(Get.context!).textTheme.headline6,
    ),
    boxShadows: [
      BoxShadow(
          offset: const Offset(0, 2),
          blurRadius: 10,
          color: ColorPalette.blue.withOpacity(0.05))
    ],
    margin: EdgeInsets.only(bottom: 40.h, left: 20.w, right: 20.w),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.white,
    borderRadius: 10,
    mainButton: TextButton(
      onPressed: () async {
        if (!isUndoButtonPressed) {
          isUndoButtonPressed = true;
          Get.back();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(Get.find<UserController>().user!.userId)
              .collection('lists')
              .doc(listModel.listId)
              .collection('items')
              .doc(item.itemId)
              .set(item.toJson());
          listModel.items?.insert(itemIndex, item.itemId);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(Get.find<UserController>().user!.userId)
              .collection('lists')
              .doc(listModel.listId)
              .set(listModel.toJson());
        }
      },
      child: Text(
        'UNDO',
        style: Theme.of(Get.context!)
            .textTheme
            .headline6!
            .copyWith(fontWeight: FontWeight.bold, color: ColorPalette.yellow),
      ),
    ),
  );
}
