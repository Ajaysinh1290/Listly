import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/models/items/order_item.dart';
import 'package:listly/screens/item/order/utils/create_item_dialog.dart';
import 'package:listly/screens/item/order/utils/delete_item.dart';
import 'package:listly/screens/item/order/utils/reset_data.dart';
import 'package:listly/screens/item/order/utils/share_data_dialog.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/utils/theme/color_palette.dart';
import 'package:listly/widgets/text-field/text_field.dart';

import 'controller/order_item_controller.dart';

class OrderItems extends StatelessWidget {
  final String listId;

  const OrderItems({Key? key, required this.listId}) : super(key: key);

  formatNumber(num number) {
    var _formattedNumber = NumberFormat.compactCurrency(
      decimalDigits: 0,
      symbol: '',
    ).format(number);
    return _formattedNumber;
  }

  @override
  Widget build(BuildContext context) {
    ListModel? listModel;
    OrderItemController itemController = Get.put(OrderItemController());
    UserController userController = Get.find();
    String title = '';

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
              tooltip: 'Reset Orders',
              padding: EdgeInsets.zero,
              onPressed: () => resetOrders(listId),
              icon: const Icon(
                Icons.restore,
                color: Colors.black,
                size: 20,
              )),
          IconButton(
              tooltip: 'Share Data',
              padding: EdgeInsets.zero,
              onPressed: () =>
                  shareDataDialog(itemController.list, title, listId),
              icon: const Icon(
                Icons.description,
                color: Colors.black,
                size: 20,
              )),
        ],
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userController.user!.userId)
              .collection('lists')
              .doc(listId)
              .get(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              listModel = ListModel.fromJson(snapshot.data.data());
            }
            return listModel == null
                ? Center(
                  child: CircularProgressIndicator(
                      color: ColorPalette.yellow,
                      strokeWidth: 1,
                    ),
                )
                : FutureBuilder<Object>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userController.user!.userId)
                        .collection('lists')
                        .doc(listId)
                        .collection('items')
                        .get(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        List<OrderItem> tempList = [];
                        for (var element in snapshot.data.docs) {
                          tempList.add(OrderItem.fromJson(element.data()));
                        }

                        itemController.list = [];
                        itemController.list!.addAll(tempList);
                        if (listModel!.items != null) {
                          for (var element in tempList) {
                            if (listModel!.items!.contains(element.itemId)) {
                              itemController.list!.remove(element);
                              int index =
                                  listModel!.items!.indexOf(element.itemId);
                              if (index <= itemController.list!.length) {
                                itemController.list!.insert(index, element);
                              }
                            }
                          }
                        }
                      }
                      return itemController.list == null
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
                                    focusNode: itemController.searchFocusNode,
                                    controller: itemController.searchController,
                                    onChanged: (value) {
                                      itemController.searchQuery = value;
                                    },
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        if (itemController
                                            .searchQuery.isNotEmpty) {
                                          itemController.searchController.text =
                                              '';
                                          itemController.searchQuery = '';
                                          return;
                                        }
                                        if (itemController
                                            .searchFocusNode.hasFocus) {
                                          itemController.searchFocusNode
                                              .unfocus();
                                        } else {
                                          itemController.searchFocusNode
                                              .requestFocus();
                                        }
                                      },
                                      icon: Obx(
                                        () => Icon(
                                          itemController.searchQuery.isEmpty
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
                                      List<OrderItem>? sortedList =
                                          itemController.list;
                                      if (itemController.searchQuery
                                          .trim()
                                          .isNotEmpty) {
                                        sortedList = itemController.list!
                                            .where((element) =>
                                                element.title
                                                    .toLowerCase()
                                                    .contains(itemController.searchQuery
                                                        .toLowerCase()
                                                        .trim()) ||
                                                element.qty.toString().contains(
                                                    itemController.searchQuery
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
                                                element.currencySymbol
                                                    .toString()
                                                    .contains(itemController.searchQuery.toLowerCase().trim()))
                                            .toList();
                                      }
                                      return ReorderableListView(
                                        padding: EdgeInsets.only(bottom: 120.h),
                                        onReorder: (int oldSortedIndex,
                                            int newSortedIndex) async {
                                          if (itemController.searchQuery
                                              .trim()
                                              .isNotEmpty) {
                                            Get.showSnackbar(GetBar(
                                              backgroundColor:
                                                  ColorPalette.yellow,
                                              duration:
                                                  const Duration(seconds: 2),
                                              message:
                                                  "List can't be reordered while searching item",
                                            ));
                                            return;
                                          }
                                          int oldIndex = oldSortedIndex;
                                          int newIndex = newSortedIndex;
                                          if (oldIndex < newIndex) {
                                            newIndex -= 1;
                                          }
                                          final item =
                                              sortedList?.removeAt(oldIndex);
                                          sortedList?.insert(newIndex, item!);
                                          itemController.list = [];
                                          itemController.list
                                              ?.addAll(sortedList!);

                                          List<String> newList = [];
                                          sortedList?.forEach((element) {
                                            newList.add(element.itemId);
                                          });
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userController.user!.userId)
                                              .collection('lists')
                                              .doc(listId)
                                              .set({'items': newList},
                                                  SetOptions(merge: true));
                                        },
                                        children: sortedList!
                                            .map((item) => Slidable(
                                                  key: UniqueKey(),
                                                  actionPane:
                                                      const SlidableDrawerActionPane(),
                                                  actions: [
                                                    IconSlideAction(
                                                      icon: Icons.assignment,
                                                      caption: 'Duplicate',
                                                      color: Colors.transparent,
                                                      foregroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      onTap: () {
                                                        itemController
                                                            .titleController
                                                            .text = item.title;
                                                        itemController
                                                                .priceController
                                                                .text =
                                                            item.price
                                                                .toString();
                                                        itemController
                                                                .currencySymbol =
                                                            item.currencySymbol;
                                                        itemController
                                                                .qtyController
                                                                .text =
                                                            item.qty.toString();
                                                        itemController
                                                            .qtyTypeController
                                                            .text = item.qtyType;

                                                        createItemDialog(
                                                            listModel!);
                                                      },
                                                    )
                                                  ],
                                                  secondaryActions: [
                                                    IconSlideAction(
                                                        icon: Icons.delete,
                                                        caption: 'Delete',
                                                        color:
                                                            Colors.transparent,
                                                        foregroundColor:
                                                            Colors.red,
                                                        onTap: () =>
                                                            onDeleteItem(item,
                                                                listModel!))
                                                  ],
                                                  child: InkWell(
                                                    onTap: () =>
                                                        createItemDialog(
                                                            listModel!,
                                                            item: item),
                                                    child: Container(
                                                      padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      10.h,
                                                                  horizontal:
                                                                      20.w)
                                                          .subtract(
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10)),
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10.h),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.r),
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              width: 1)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                    item.title
                                                                            .isEmpty
                                                                        ? 'Untitled'
                                                                        : item
                                                                            .title,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline6!
                                                                        .copyWith(
                                                                            fontWeight:
                                                                                FontWeight.bold)),
                                                              ),
                                                              SizedBox(
                                                                width: 10.w,
                                                              ),
                                                              Text(
                                                                '${item.currencySymbol}${item.price < 1000000 ? item.price : formatNumber(item.price)}',
                                                                style: Theme.of(
                                                                        context)
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
                                                            height: 5.h,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Flexible(
                                                                flex: 2,
                                                                child: Row(
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        if (item.qty !=
                                                                            0) {
                                                                          itemController.onDecrement(
                                                                              item,
                                                                              listModel!);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(10.0),
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Icon(
                                                                            Icons.remove,
                                                                            size:
                                                                                20.sp,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          color: ColorPalette.yellow.withOpacity(item.qty == 0
                                                                              ? 0.4
                                                                              : 1),
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 5.w),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          5.w,
                                                                    ),
                                                                    Text(
                                                                        '${item.qty < 1000000 ? item.qty : formatNumber(item.qty)}',
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .headline6),
                                                                    SizedBox(
                                                                      width:
                                                                          5.w,
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () => itemController.onIncrement(
                                                                          item,
                                                                          listModel!),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(10),
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Icon(
                                                                            Icons.add,
                                                                            size:
                                                                                20.sp,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                          color:
                                                                              ColorPalette.blue,
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 5.w),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Flexible(
                                                                flex: 1,
                                                                child: Text(
                                                                    item
                                                                        .qtyType,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline6!
                                                                        .copyWith(
                                                                          fontSize:
                                                                              18.sp,
                                                                        )),
                                                              ),
                                                            ],
                                                          ),
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
                    });
          }),
      floatingActionButton: Tooltip(
        message: 'Add Item',
        child: InkWell(
          onTap: () async {
            itemController.titleController.text = '';
            itemController.priceController.text = '';
            itemController.qtyController.text = '';

            createItemDialog(listModel!);
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
