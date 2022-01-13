import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:listly/models/items/todo_item.dart';
import 'package:listly/screens/item/order/controller/order_item_controller.dart';
import 'package:listly/screens/item/todo/controller/todo_item_controller.dart';
import 'package:listly/widgets/dialog/show_loading.dart';

void deleteCompletedTasks(String listId) async {
  showLoading("Deleting completed tasks..");
  TodoItemsController itemController = Get.find();
  if (itemController.list == null) {
    return;
  }
  List<TodoItem>? temp = [];
  temp.addAll(itemController.list!);
  String userId = Get.find<UserController>().user!.userId;
  for (var item in itemController.list!) {
    if (item.isDone) {
      temp.remove(item);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('lists')
          .doc(listId)
          .collection('items')
          .doc(item.itemId)
          .delete();
    }
    itemController.list = temp;
  }
  List<String> newList = [];
  itemController.list?.forEach((element) {
    newList.add(element.itemId);
  });
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('lists')
      .doc(listId)
      .set({'items': newList},
      SetOptions(merge: true));
  itemController.refreshDataOnScreen();
  Get.back();
}
