import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/utils/theme/color_palette.dart';
import 'delete_list.dart';

showDeleteConfirmationDialog(ListModel listModel) {
  Get.dialog(AlertDialog(
    title: Text(
      'Are you really want to delete this List ?',
      style: Theme.of(Get.context!).textTheme.headline6,
    ),
    actions: [
      TextButton(
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          Get.back();
        },
      ),
      ElevatedButton(
        onPressed: () {
          Get.back();
          deleteList(listModel);
        },
        child: const Text(
          'Delete',
          style: TextStyle(color: Colors.white),
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(ColorPalette.blue)),
      )
    ],
  ));
}
