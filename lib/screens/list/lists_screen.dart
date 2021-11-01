import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/screens/item/items.dart';
import 'package:listly/screens/list/utils/list_delete_confirmation_dialog.dart';
import 'package:listly/screens/list/utils/temp.dart';
import 'package:listly/screens/profile/user_profile.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/utils/theme/color_palette.dart';
import 'package:listly/widgets/text-field/text_field.dart';

import 'controller/list_controller.dart';
import 'utils/create_list.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ListController homeController = Get.put(ListController());
    UserController userController = Get.find();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75.w,
        leadingWidth: 75.w,
        leading: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.r),
            child: Obx(() {
              return Tooltip(
                message: 'Your Profile',
                child: GestureDetector(
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
                ),
              );
            }),
          ),
        ),
        title: const Text('Listly'),
        actions: [
          IconButton(
            onPressed: () => Get.to(Temp()),
            icon: const Icon(Icons.restore),
          )
        ],
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
                : Padding(
                    padding: Constants.scaffoldPadding,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        MyTextField(
                          labelText: 'Search',
                          focusNode: homeController.searchFocusNode,
                          controller: homeController.searchController,
                          onChanged: (value) {
                            homeController.searchQuery = value;
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              if (homeController.searchQuery.isNotEmpty) {
                                homeController.searchController.text = '';
                                homeController.searchQuery = '';
                                return;
                              }
                              if (homeController.searchFocusNode.hasFocus) {
                                homeController.searchFocusNode.unfocus();
                              } else {
                                homeController.searchFocusNode.requestFocus();
                              }
                            },
                            icon: Obx(
                              () => Icon(
                                homeController.searchQuery.isEmpty
                                    ? Icons.search
                                    : Icons.clear,
                                size: 30.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Expanded(
                          child: Obx(() {
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
                            return ListView(
                              padding: EdgeInsets.only(bottom: 110.h),
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
                                            onTap: () => createList(
                                                listModel: listModel),
                                          )
                                        ],
                                        secondaryActions: [
                                          IconSlideAction(
                                              icon: Icons.delete,
                                              caption: 'Delete',
                                              color: Colors.transparent,
                                              foregroundColor: Colors.red,
                                              onTap: () {
                                                showDeleteConfirmationDialog(
                                                    listModel);
                                              }),
                                          // onTap: () => homeController
                                          //     .onDeleteList(listModel, context))
                                        ],
                                        child: InkWell(
                                          onTap: () => Get.to(Items(
                                            listId: listModel.listId,
                                          )),
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.h,
                                                horizontal: 20.w),
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
                                                                FontWeight
                                                                    .bold)),
                                                SizedBox(
                                                  height: 5.h,
                                                ),
                                                Text(
                                                    '${(listModel.items?.length) ?? 0} Items',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6!
                                                        .copyWith(
                                                            fontSize: 16.sp)),
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
                                                                .withOpacity(
                                                                    0.2),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
          }),
      floatingActionButton: Tooltip(
        message: 'Add List',
        child: InkWell(
          onTap: createList,
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
      ),
    );
  }
}
