import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/screens/home/controller/home_controller.dart';
import 'package:listly/screens/item/items.dart';
import 'package:listly/screens/profile/user_profile.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/utils/theme/color_palette.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _onDelete(ListModel listModel, BuildContext context) async {
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
      forwardAnimationCurve: Curves.elasticInOut,
      animationDuration: const Duration(seconds: 2),
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

  _createList({ListModel? listModel}) {
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

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());
    UserController userController = Get.find();
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 75.w,
        leading: Padding(
          padding: EdgeInsets.all(20.0.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.r),
            child: Obx(() {
              return GestureDetector(
                onTap: () => Get.to(UserProfile()),
                child: userController.user!.profilePic != null
                    ? Image.network(
                        userController.user!.profilePic!,
                        width: 85.w,
                        height: 35.w,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 35.w,
                        height: 35.w,
                        color: ColorPalette.blue,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
              );
            }),
          ),
        ),
        title: const Text('Listly'),
      ),
      body: StreamBuilder<Object>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userController.user!.userId)
              .collection('lists')
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            List<ListModel>? list;
            if (snapshot.hasData) {
              list = [];
              for (var element in snapshot.data.docs) {
                list.add(ListModel.fromJson(element.data()));
              }
            }
            return list == null
                ? Center(
                    child: CircularProgressIndicator(
                    color: ColorPalette.yellow,
                    strokeWidth: 1.4,
                  ))
                : ListView(
                    padding: Constants.scaffoldPadding,
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                      MyTextField(
                        labelText: 'Search',
                        onChanged: (value) {
                          homeController.searchQuery = value;
                        },
                        suffixIcon: Icon(
                          Icons.search,
                          size: 22.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Obx(() {
                        List<ListModel>? sortedList = list;
                        if (homeController.searchQuery.trim().isNotEmpty) {
                          sortedList = list!
                              .where((element) => element.title
                                  .toLowerCase()
                                  .contains(homeController.searchQuery
                                      .toLowerCase()
                                      .trim()))
                              .toList();
                        }
                        return Column(
                          children: sortedList!
                              .map((listModel) => Slidable(
                                    actionPane:
                                        const SlidableDrawerActionPane(),
                                    actions: [
                                      IconSlideAction(
                                        icon: Icons.edit,
                                        caption: 'Edit',
                                        color: Colors.transparent,
                                        foregroundColor:
                                            Theme.of(context).primaryColor,
                                        onTap: () =>
                                            _createList(listModel: listModel),
                                      )
                                    ],
                                    secondaryActions: [
                                      IconSlideAction(
                                          icon: Icons.delete,
                                          caption: 'Delete',
                                          color: Colors.transparent,
                                          foregroundColor: Colors.red,
                                          onTap: () =>
                                              _onDelete(listModel, context))
                                    ],
                                    child: InkWell(
                                      onTap: () => Get.to(Items(
                                        listId: listModel.listId,
                                      )),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h, horizontal: 20.w),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.r),
                                            border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                listModel.title.isEmpty
                                                    ? 'Untitled'
                                                    : listModel.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            StreamBuilder<Object>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .doc(userController
                                                        .user!.userId)
                                                    .collection('lists')
                                                    .doc(listModel.listId)
                                                    .collection('items')
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot snapshot) {
                                                  int totalItems = 0;
                                                  if (snapshot.hasData) {
                                                    totalItems = snapshot
                                                        .data.docs.length;
                                                  }
                                                  return Text(
                                                      '$totalItems Items',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6!
                                                          .copyWith(
                                                              fontSize: 16.sp));
                                                }),
                                            SizedBox(
                                              height: 15.h,
                                            ),
                                            Text(
                                                'Created on ${Constants.dateFormat.format(listModel.createdOn)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6!
                                                    .copyWith(
                                                        fontSize: 14.sp,
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        fontWeight:
                                                            FontWeight.bold))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      }),
                    ],
                  );
          }),
      floatingActionButton: InkWell(
        onTap: _createList,
        child: Container(
          margin: const EdgeInsets.all(10.0),
          width: 75.w,
          height: 75.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30.sp,
          ),
        ),
      ),
    );
  }
}
