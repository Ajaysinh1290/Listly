import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/models/items/order_item.dart';
import 'package:listly/utils/constants/constants.dart';

class OrderItemController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController qtyTypeController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final RxString _currencySymbol = RxString(Constants.currencySymbols.first);
  FocusNode searchFocusNode = FocusNode();
  final Rx<List<OrderItem>?> _list = Rxn<List<OrderItem>?>();

  set list(List<OrderItem>? value) {
    _list.value = value;
  } // final RxString _qtyType = RxString(Constants.qtyTypes.first);

  List<OrderItem>? get list => _list.value;

  RxBool isLoading = RxBool(false);
  GlobalKey<FormState> formKey = GlobalKey();
  OrderItem? _item;

  OrderItem? get item => _item;
  final RxString _searchQuery = RxString('');

  String get searchQuery => _searchQuery.value;

  set searchQuery(String value) {
    _searchQuery.value = value;
  }

  set item(OrderItem? item) {
    _item = item;
    titleController.text = '';
    priceController.text = '';
    qtyController.text = '';

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
        double number = double.parse(priceController.text.trim());
        if (number < 0) {
          return "Please enter positive value";
        }
      } on FormatException catch (_) {
        return 'Please enter numeric characters only';
      }
    }
    return null;
  }

  String? validateQty(value) {
    if (qtyController.text.trim().isEmpty) {
      return 'Price can\'t be empty';
    } else {
      try {
        double number = double.parse(qtyController.text.trim());
        if (number < 0) {
          return "Please enter positive value";
        }
      } on FormatException catch (_) {
        return 'Please enter numeric characters only';
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
      refreshDataOnScreen();
      titleController.text = '';
      priceController.text = '';
      qtyController.text = '';
      isLoading.value = false;
      item = null;
      Get.back();
    }
  }

  addItem(ListModel listModel) async {
    String userId = Get.find<UserController>().user!.userId;
    item = OrderItem(
        title: titleController.text,
        price: num.parse(priceController.text),
        currencySymbol: currencySymbol,
        itemId: DateTime.now().millisecondsSinceEpoch.toString(),
        qty: num.parse(qtyController.text),
        qtyType: qtyTypeController.text);
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listModel.listId)
        .collection('items')
        .doc(item!.itemId)
        .set(item!.toJson());
    listModel.items ??= [];
    listModel.items!.add(item!.itemId);
    list ??= [];
    list?.add(item!);
    FirebaseFirestore.instance
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
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(item!.itemId)
        .set(item!.toJson());
  }

  onDecrement(OrderItem item, ListModel listModel) async {
    item.qty -= 1;
    _saveQty(item, listModel);
  }

  onIncrement(OrderItem item, ListModel listModel) {
    item.qty += 1;
    _saveQty(item, listModel);
  }

  _saveQty(OrderItem item, ListModel listModel) {
    refreshDataOnScreen();
    FirebaseFirestore.instance
        .collection('users')
        .doc(Get.find<UserController>().user!.userId)
        .collection('lists')
        .doc(listModel.listId)
        .collection('items')
        .doc(item.itemId)
        .set({'qty': item.qty}, SetOptions(merge: true));
  }

  refreshDataOnScreen() {
    List<OrderItem>? tempList = list;
    list = [];
    list?.addAll(tempList!);
  }
}
