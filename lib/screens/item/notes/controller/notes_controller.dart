import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/items/notes.dart';
import 'package:listly/models/list_model.dart';

class NotesController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  final Rx<List<Note>?> _list = Rxn<List<Note>?>();

  set list(List<Note>? value) {
    _list.value = value;
  }

  List<Note>? get list => _list.value;

  RxBool isLoading = RxBool(false);
  GlobalKey<FormState> formKey = GlobalKey();
  Note? _item;

  Note? get item => _item;
  final RxString _searchQuery = RxString('');

  String get searchQuery => _searchQuery.value;

  set searchQuery(String value) {
    _searchQuery.value = value;
  }

  set item(Note? item) {
    _item = item;
    titleController.text = '';
    descriptionController.text = '';

    if (item != null) {
      titleController.text = item.title;
      descriptionController.text = item.description ?? '';
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
      descriptionController.text = '';
      isLoading.value = false;
      item = null;
      Get.back();
    }
  }

  addItem(ListModel listModel) async {
    String userId = Get.find<UserController>().user!.userId;
    item = Note(
        title: titleController.text,
        itemId: DateTime.now().millisecondsSinceEpoch.toString(),
        description: descriptionController.text.trim());
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
    item!.description = descriptionController.text;
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
    List<Note>? tempList = list;
    list = [];
    list?.addAll(tempList!);
  }
}
