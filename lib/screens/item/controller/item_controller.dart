import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/item.dart';
import 'package:listly/utils/constants/constants.dart';

class ItemController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  final RxString _currencySymbol = RxString(Constants.currencySymbols.first);
  final RxString _qtyType = RxString(Constants.qtyTypes.first);
  RxBool isLoading = RxBool(false);
  GlobalKey<FormState> formKey = GlobalKey();
  Item? _item;

  Item? get item => _item;
  final RxString _searchQuery = RxString('');

  String get searchQuery => _searchQuery.value;

  set searchQuery(String value) {
    _searchQuery.value = value;
  }

  set item(Item? item) {
    _item = item;
    if (item != null) {
      titleController.text = item.title;
      priceController.text = item.price.toString();
      qtyController.text = item.qty.toString();
      currencySymbol = item.currencySymbol;
      qtyType = item.qtyType;
    }
  }

  set currencySymbol(String value) => _currencySymbol.value = value;

  String get currencySymbol => _currencySymbol.value;

  set qtyType(String value) => _qtyType.value = value;

  String get qtyType => _qtyType.value;

  String? validatePrice(value) {
    if (priceController.text.trim().isEmpty) {
      return 'Price can\'t be empty';
    } else {
      try {
        double.parse(priceController.text.trim());
      } on FormatException catch (_) {
        return 'Only numbers are allowed';
      }
    }
    return null;
  }

  String? validateQty(value) {
    if (qtyController.text.trim().isEmpty) {
      return 'Qty can\'t be empty';
    } else {
      try {
        int.parse(qtyController.text.trim());
      } on FormatException catch (_) {
        return 'Only numbers are allowed';
      }
    }
    return null;
  }

  String? validateTitle(value) {
    if (titleController.text.trim().isEmpty) {
      return 'Title can\'t be empty';
    }
    return null;
  }

  createItem(String listId) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      if (item == null) {
        await addItem(listId);
      } else {
        await updateItem(listId);
      }
      titleController.text = '';
      priceController.text = '';
      qtyController.text = '';
      isLoading.value = false;
      Get.back();
    }
  }

  addItem(String listId) async {
    String userId = Get.find<UserController>().user!.userId;
    item = Item(
        title: titleController.text,
        price: num.parse(priceController.text),
        currencySymbol: currencySymbol,
        itemId: DateTime.now().millisecondsSinceEpoch.toString(),
        qty: int.parse(qtyController.text),
        qtyType: qtyType);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(item!.itemId)
        .set(item!.toJson());
  }

  updateItem(String listId) async {
    String userId = Get.find<UserController>().user!.userId;
    item!.title = titleController.text;
    item!.price = num.parse(priceController.text);
    item!.qty = int.parse(qtyController.text);
    item!.qtyType = qtyType;
    item!.currencySymbol = currencySymbol;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(item!.itemId)
        .set(item!.toJson());
  }
}
