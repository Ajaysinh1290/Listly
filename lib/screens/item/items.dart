import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/item.dart';
import 'package:listly/screens/item/controller/item_controller.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/utils/theme/color_palette.dart';
import 'package:listly/widgets/text-field/text_field.dart';
import 'package:share/share.dart';

import 'create_pdf.dart';

class Items extends StatelessWidget {
  final String listId;

  const Items({Key? key, required this.listId}) : super(key: key);

  _onTap(List<Item>? items, String title) {
    if (items == null) {
      return;
    }
    Get.bottomSheet(Container(
        margin: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20.h,
            ),
            InkWell(
              onTap: () {
                Get.back();
                List<Item> sortedList =
                    items.where((element) => element.qty != 0).toList();
                createPdf(sortedList, title, listId);
              },
              child: SizedBox(
                width: double.infinity,
                height: 40.h,
                child: Text(
                  'Create Pdf',
                  style: Theme.of(Get.context!).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
              width: double.infinity,
              height: 1,
              color: Colors.grey.shade300,
            ),
            SizedBox(
              height: 10.h,
            ),
            InkWell(
              onTap: () async {
                String message = title + '\n\n';
                for (Item item in items) {
                  if (item.qty != 0) {
                    message +=
                        '${item.title} (${item.price}${item.currencySymbol}) - ${item.qty} ${item.qtyType}\n';
                  }
                }
                Get.back();
                await Share.share(message);
              },
              child: SizedBox(
                width: double.infinity,
                height: 40.h,
                child: Text(
                  'Share as Message',
                  style: Theme.of(Get.context!).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            )
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    ItemController itemController = Get.put(ItemController());
    UserController userController = Get.find();
    String title = '';
    List<Item>? list;
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<Object>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userController.user!.userId)
                .collection('lists')
                .doc(listId)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                title = snapshot.data.data()['title'];
              }
              return Text(title);
            }),
        actions: [
          IconButton(
              tooltip: 'Share Data',
              onPressed: () => _onTap(list, title),
              icon: const Icon(
                Icons.description,
                color: Colors.black,
                size: 20,
              ))
        ],
      ),
      body: StreamBuilder<Object>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userController.user!.userId)
              .collection('lists')
              .doc(listId)
              .collection('items')
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              list = [];
              for (var element in snapshot.data.docs) {
                list!.add(Item.fromJson(element.data()));
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
                          itemController.searchQuery = value;
                        },
                        suffixIcon: Icon(
                          Icons.search,
                          size: 30.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Obx(() {
                        List<Item>? sortedList = list;
                        if (itemController.searchQuery.trim().isNotEmpty) {
                          sortedList = list!
                              .where((element) =>
                                  element.title.toLowerCase().contains(
                                      itemController.searchQuery
                                          .toLowerCase()
                                          .trim()) ||
                                  element.qty.toString().contains(itemController
                                      .searchQuery
                                      .toLowerCase()
                                      .trim()) ||
                                  element.qtyType.toLowerCase().contains(
                                      itemController.searchQuery
                                          .toLowerCase()
                                          .trim()) ||
                                  element.price.toString().contains(
                                      itemController.searchQuery
                                          .toLowerCase()
                                          .trim()) ||
                                  element.currencySymbol.toString().contains(
                                      itemController.searchQuery
                                          .toLowerCase()
                                          .trim()))
                              .toList();
                        }
                        return Column(
                          children: sortedList!
                              .map((item) => Slidable(
                                    key: UniqueKey(),
                                    actionPane:
                                        const SlidableDrawerActionPane(),
                                    actions: [
                                      IconSlideAction(
                                        icon: Icons.edit,
                                        caption: 'Edit',
                                        color: Colors.transparent,
                                        foregroundColor:
                                            Theme.of(context).primaryColor,
                                        onTap: () => itemController
                                            .createItemDialog(listId,
                                                item: item),
                                      )
                                    ],
                                    secondaryActions: [
                                      IconSlideAction(
                                          icon: Icons.delete,
                                          caption: 'Delete',
                                          color: Colors.transparent,
                                          foregroundColor: Colors.red,
                                          onTap: () => itemController
                                              .onDeleteItem(item, listId))
                                    ],
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10.h, horizontal: 20.w),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10.h),
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                    item.title.isEmpty
                                                        ? 'Untitled'
                                                        : item.title,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                              ),
                                              Text(
                                                '${item.currencySymbol}${item.price}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .copyWith(
                                                        fontFamily:
                                                            GoogleFonts.roboto()
                                                                .fontFamily,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15.h,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  AbsorbPointer(
                                                    absorbing: item.qty == 0,
                                                    child: InkWell(
                                                      onTap: () =>
                                                          itemController
                                                              .onDecrement(
                                                                  item, listId),
                                                      child: Container(
                                                        child: Icon(
                                                          Icons.remove,
                                                          size: 20.sp,
                                                          color: Colors.white,
                                                        ),
                                                        color: ColorPalette
                                                            .yellow
                                                            .withOpacity(
                                                                item.qty == 0
                                                                    ? 0.4
                                                                    : 1),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    5.w),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 15.w,
                                                  ),
                                                  Text('${item.qty}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6!
                                                          .copyWith(
                                                            fontSize: 16.sp,
                                                          )),
                                                  SizedBox(
                                                    width: 15.w,
                                                  ),
                                                  InkWell(
                                                    onTap: () => itemController
                                                        .onIncrement(
                                                            item, listId),
                                                    child: Container(
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 20.sp,
                                                        color: Colors.white,
                                                      ),
                                                      color: ColorPalette.blue,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.w),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(item.qtyType,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6!
                                                      .copyWith(
                                                        fontSize: 16.sp,
                                                      )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      }),
                      SizedBox(
                        height: 110.h,
                      )
                    ],
                  );
          }),
      floatingActionButton: Tooltip(
        message: 'Add Item',
        child: InkWell(
          onTap: () async {
            await itemController.createItemDialog(listId);
          },
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
