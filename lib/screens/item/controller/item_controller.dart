import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/item.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/utils/constants/constants.dart';

class ItemController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController qtyTypeController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final RxString _currencySymbol = RxString(Constants.currencySymbols.first);
  FocusNode searchFocusNode = FocusNode();

  // final RxString _qtyType = RxString(Constants.qtyTypes.first);
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
      qtyTypeController.text = item.qtyType;
    }
  }

  set currencySymbol(String value) => _currencySymbol.value = value;

  String get currencySymbol => _currencySymbol.value;

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
      return 'Price can\'t be empty';
    } else {
      try {
        double.parse(qtyController.text.trim());
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

  createItem(ListModel listModel) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      if (item == null) {
        await addItem(listModel);
      } else {
        await updateItem(listModel.listId);
      }
      titleController.text = '';
      priceController.text = '';
      qtyController.text = '';
      isLoading.value = false;
      Get.back();
    }
  }

  addItem(ListModel listModel) async {
    String userId = Get.find<UserController>().user!.userId;
    item = Item(
        title: titleController.text,
        price: num.parse(priceController.text),
        currencySymbol: currencySymbol,
        itemId: DateTime.now().millisecondsSinceEpoch.toString(),
        qty: num.parse(qtyController.text),
        qtyType: qtyTypeController.text);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listModel.listId)
        .collection('items')
        .doc(item!.itemId)
        .set(item!.toJson());
    listModel.items ??= [];
    listModel.items!.add(item!.itemId);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listModel.listId)
        .set(listModel.toJson());
  }

  updateItem(String listId) async {
    String userId = Get.find<UserController>().user!.userId;
    item!.title = titleController.text;
    item!.price = num.parse(priceController.text);
    item!.qty = int.parse(qtyController.text);
    item!.qtyType = qtyTypeController.text;
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

  onDecrement(Item item, ListModel listModel) async {
    item.qty -= 1;
    await _saveQty(item, listModel);
  }

  onIncrement(Item item, ListModel listModel) async {
    item.qty += 1;
    await _saveQty(item, listModel);
  }

  _saveQty(Item item, ListModel listModel) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Get.find<UserController>().user!.userId)
        .collection('lists')
        .doc(listModel.listId)
        .collection('items')
        .doc(item.itemId)
        .set({'qty': item.qty}, SetOptions(merge: true));
  }
}
