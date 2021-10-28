import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/utils/theme/color_palette.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';

class HomeController extends GetxController {
  TextEditingController titleController = TextEditingController();
  RxBool isLoading = RxBool(false);
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

  createList({ListModel? listModel}) {
    HomeController homeController = Get.find();
    homeController.titleController.text = '';
    homeController.listModel = listModel;
    Get.bottomSheet(Container(
      padding: EdgeInsets.all(20.0.w),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10.h,
          ),
          MyTextField(
            labelText: 'List Title',
            controller: homeController.titleController,
          ),
          SizedBox(
            height: 20.h,
          ),
          Obx(() {
            return MyButton(
              onPressed: () async {
                await homeController.createTitle();
                Get.back();
              },
              buttonText: listModel == null ? 'Create' : 'Update',
              isLoading: homeController.isLoading.value,
            );
          }),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    ));
  }

  void onDeleteList(ListModel listModel, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Get.find<UserController>().user!.userId)
        .collection('lists')
        .doc(listModel.listId)
        .delete();

    bool isUndoButtonPressed = false;

    Get.snackbar(
      '',
      '',
      animationDuration: const Duration(milliseconds: 500),
      titleText: Text(
        'List Deleted Successfully',
        style: Theme.of(context)
            .textTheme
            .headline6!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      messageText: Text(
        listModel.title.isEmpty ? 'Untitled' : listModel.title,
        style: Theme.of(context).textTheme.headline6,
      ),
      boxShadows: [
        BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 10,
            color: ColorPalette.blue.withOpacity(0.05))
      ],
      margin: EdgeInsets.only(bottom: 40.h, left: 20.w, right: 20.w),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      borderRadius: 10,
      mainButton: TextButton(
        onPressed: () async {
          if (!isUndoButtonPressed) {
            isUndoButtonPressed = true;
            Get.back();
            await FirebaseFirestore.instance
                .collection('users')
                .doc(Get.find<UserController>().user!.userId)
                .collection('lists')
                .doc(listModel.listId)
                .set(listModel.toJson());
          }
        },
        child: Text(
          'UNDO',
          style: Theme.of(context).textTheme.headline6!.copyWith(
              fontWeight: FontWeight.bold, color: ColorPalette.yellow),
        ),
      ),
    );
  }
}
