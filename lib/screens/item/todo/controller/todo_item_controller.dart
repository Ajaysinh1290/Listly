import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/items/todo_item.dart';
import 'package:listly/models/list_model.dart';

class TodoItemsController extends GetxController {
  TextEditingController titleController = TextEditingController();
  final RxBool _isDone = RxBool(false);
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  final Rx<List<TodoItem>?> _list = Rxn<List<TodoItem>?>();

  set list(List<TodoItem>? value) {
    _list.value = value;
  }

  List<TodoItem>? get list => _list.value;

  set isDone(value) {
    _isDone.value = value;
  }

  get isDone => _isDone.value;

  RxBool isLoading = RxBool(false);
  GlobalKey<FormState> formKey = GlobalKey();
  TodoItem? _item;

  TodoItem? get item => _item;
  final RxString _searchQuery = RxString('');

  String get searchQuery => _searchQuery.value;

  set searchQuery(String value) {
    _searchQuery.value = value;
  }

  set item(TodoItem? item) {
    _item = item;
    titleController.text = '';
    isDone = false;

    if (item != null) {
      titleController.text = item.title;
      isDone = item.isDone;
    }
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
      isDone = false;
      isLoading.value = false;
      Get.back();
    }
  }

  addItem(ListModel listModel) async {
    String userId = Get.find<UserController>().user!.userId;
    item = TodoItem(
        title: titleController.text,
        itemId: DateTime.now().millisecondsSinceEpoch.toString(),
        isDone: isDone);
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
    item!.isDone = isDone;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(item!.itemId)
        .set(item!.toJson());
  }

  refreshDataOnScreen() {
    List<TodoItem>? tempList = list;
    list = [];
    list?.addAll(tempList!);
  }
}
