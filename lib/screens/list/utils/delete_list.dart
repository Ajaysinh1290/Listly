import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/widgets/dialog/show_loading.dart';
import 'package:get/get.dart';

void deleteList(ListModel listModel) async {
  showLoading('Deleting List...');
  if (listModel.items != null && listModel.items!.isNotEmpty) {
    for (String itemId in listModel.items!) {
      await Future.delayed(const Duration(milliseconds: 100));
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Get.find<UserController>().user!.userId)
          .collection('lists')
          .doc(listModel.listId)
          .collection('items')
          .doc(itemId)
          .delete();
    }
  }
  await FirebaseFirestore.instance
      .collection('users')
      .doc(Get.find<UserController>().user!.userId)
      .collection('lists')
      .doc(listModel.listId)
      .delete();
  Get.back();
}
