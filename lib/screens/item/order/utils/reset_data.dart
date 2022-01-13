import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:listly/screens/item/order/controller/order_item_controller.dart';
import 'package:listly/widgets/dialog/show_loading.dart';

void resetOrders(String listId) async {
  showLoading("Resetting Orders..");
  OrderItemController itemController = Get.find();
  if (itemController.list == null) {
    return;
  }
  for (var item in itemController.list!) {
    if (item.qty != 0) {
      item.qty = 0;
      String userId = Get.find<UserController>().user!.userId;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('lists')
          .doc(listId)
          .collection('items')
          .doc(item.itemId)
          .set(item.toJson());
    }
  }
  itemController.refreshDataOnScreen();
  Get.back();
}
