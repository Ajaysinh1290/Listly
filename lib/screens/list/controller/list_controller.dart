import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/utils/constants/list_type.dart';

class ListController extends GetxController {
  TextEditingController titleController = TextEditingController();
  final RxString _listType = RxString(Constants.listTypes.first);

  String get listType => _listType.value;

  set listType(String value) {
    _listType.value = value;
  }

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
      listType = listModel.listType;
    }
  }

  ListModel? get listModel => _listModel;

  createList() async {
    isLoading.value = true;

    if (listModel == null) {
      await addNewList();
    } else {
      await updateList();
    }
    titleController.text = '';
    isLoading.value = false;
  }

  addNewList() async {
    String userId = Get.find<UserController>().user!.userId;
    ListModel listModel = ListModel(
        listId: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text,
        listType: listType,
        createdOn: DateTime.now());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listModel.listId)
        .set(listModel.toJson());
  }

  updateList() async {
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
