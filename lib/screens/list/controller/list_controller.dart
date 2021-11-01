import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/list_model.dart';

class ListController extends GetxController {
  TextEditingController titleController = TextEditingController();
  RxBool isLoading = RxBool(false);
  FocusNode searchFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController();
  final RxString _searchQuery = RxString('');

  String get searchQuery => _searchQuery.value;

  set searchQuery(String value) {
    _searchQuery.value = value;
  }

  ListModel? _listModel;

  set listModel(ListModel? listModel) {
    _listModel = listModel;
    if (listModel != null) {
      titleController.text = listModel.title;
    }
  }

  ListModel? get listModel => _listModel;

  createTitle() async {
    isLoading.value = true;

    if (listModel == null) {
      await addNewTitle();
    } else {
      await updateTitle();
    }
    titleController.text = '';
    isLoading.value = false;
  }

  addNewTitle() async {
    String userId = Get.find<UserController>().user!.userId;
    ListModel listModel = ListModel(
        listId: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text,
        createdOn: DateTime.now());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listModel.listId)
        .set(listModel.toJson());
  }

  updateTitle() async {
    String userId = Get.find<UserController>().user!.userId;
    _listModel!.title = titleController.text;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listModel!.listId)
        .set(listModel!.toJson());
  }


}