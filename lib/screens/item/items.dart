import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/item.dart';
import 'package:listly/screens/item/controller/item_controller.dart';
import 'package:listly/screens/item/save_and_launch_file.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/utils/theme/color_palette.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';
import 'package:share/share.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class Items extends StatelessWidget {
  final String listId;

  const Items({Key? key, required this.listId}) : super(key: key);

  Future<void> _createPdf(List<Item>? items, String title) async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();
    final ByteData data =
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final fontData =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final Size pageSize = page.getClientSize();
    page.graphics.drawString(title, PdfTrueTypeFont(fontData, 30),
        bounds: Rect.fromLTWH(0, 20, pageSize.width - 200, 100));
    page.graphics.drawString(
      'Date : ' + Constants.onlyDateFormat.format(DateTime.now()),
      PdfTrueTypeFont(
        fontData,
        22,
      ),
      bounds: Rect.fromLTWH(pageSize.width - 180, 25, pageSize.width, 40),
    );

    PdfGrid grid = PdfGrid();

    grid.style = PdfGridStyle(
      font: PdfTrueTypeFont(fontData, 22),
      cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2),
    );
    grid.columns.add(count: 4);
    grid.columns[0].width = 40;
    grid.columns[1].width = 250;
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = '';
    header.cells[1].value = 'Item';
    header.cells[2].value = 'Price';
    header.cells[3].value = 'Qty';

    if (items != null) {
      for (int i = 0; i < items.length; i++) {
        Item item = items[i];
        PdfGridRow row = grid.rows.add();
        row.cells[0].value = (i + 1).toString();
        row.cells[1].value = item.title;
        row.cells[2].value = '${item.price} ${item.currencySymbol}';
        row.cells[3].value = item.qty.toString() + ' ' + item.qtyType;
      }
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    grid.draw(
        page: page,
        bounds: Rect.fromLTWH(0, 110, pageSize.width, pageSize.height));
    List<int> bytes = document.save();
    document.dispose();

    saveAndLaunchFile(bytes, '$listId.pdf');
  }

  _createItem({Item? item}) {
    ItemController itemController = Get.find();
    itemController.titleController.text = '';
    itemController.priceController.text = '';
    itemController.qtyController.text = '';
    itemController.item = item;
    Get.bottomSheet(Container(
      padding: EdgeInsets.all(20.0.w),
      color: Colors.white,
      child: Builder(builder: (context) {
        return SingleChildScrollView(
          child: Form(
            key: itemController.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10.h,
                ),
                MyTextField(
                  labelText: 'Item Title',
                  controller: itemController.titleController,
                  validator: itemController.validateTitle,
                ),
                SizedBox(
                  height: 20.h,
                ),
                MyTextField(
                  labelText: 'Price',
                  textInputType: TextInputType.number,
                  validator: itemController.validatePrice,
                  controller: itemController.priceController,
                  suffixIcon: Obx(() {
                    return DropdownButton(
                        underline: Container(),
                        value: itemController.currencySymbol,
                        onChanged: (value) {
                          itemController.currencySymbol = value.toString();
                        },
                        items: Constants.currencySymbols
                            .map(
                              (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontFamily:
                                                GoogleFonts.roboto().fontFamily,
                                            fontWeight: FontWeight.normal),
                                  )),
                            )
                            .toList());
                  }),
                ),
                SizedBox(
                  height: 20.h,
                ),
                MyTextField(
                  labelText: 'Qty',
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  textInputType: const TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  controller: itemController.qtyController,
                  validator: itemController.validateQty,
                ),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1)),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    child: Obx(() {
                      return DropdownButton(
                          underline: Container(),
                          isExpanded: true,
                          value: itemController.qtyType,
                          onChanged: (value) {
                            itemController.qtyType = value.toString();
                          },
                          items: Constants.qtyTypes
                              .map(
                                (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6)),
                              )
                              .toList());
                    }),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Obx(() {
                  return MyButton(
                    onPressed: () async {
                      await itemController.createItem(listId);
                    },
                    buttonText: item != null ? 'Update Item' : 'Add Item',
                    isLoading: itemController.isLoading.value,
                  );
                }),
                SizedBox(
                  height: 10.h,
                ),
              ],
            ),
          ),
        );
      }),
    ));
  }

  void _onDelete(Item item, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Get.find<UserController>().user!.userId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(item.itemId)
        .delete();

    bool isUndoButtonPressed = false;
    Get.snackbar(
      '',
      '',
      forwardAnimationCurve: Curves.elasticInOut,
      animationDuration: const Duration(seconds: 2),
      titleText: Text(
        'Item Deleted Successfully',
        style: Theme.of(context)
            .textTheme
            .headline6!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      messageText: Text(
        item.title,
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
                .doc(listId)
                .collection('items')
                .doc(item.itemId)
                .set(item.toJson());
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
                _createPdf(items, title);
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
                String message = title + '\n';
                for (Item item in items) {
                  message +=
                      '${item.title} (${item.price}${item.currencySymbol}) - ${item.qty} ${item.qtyType}\n';
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
              onPressed: () => _onTap(list, title),
              icon: Icon(
                Icons.description,
                color: Colors.black,
                size: 22.sp,
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
                          size: 22.sp,
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
                                    actionPane:
                                        const SlidableDrawerActionPane(),
                                    actions: [
                                      IconSlideAction(
                                        icon: Icons.edit,
                                        caption: 'Edit',
                                        color: Colors.transparent,
                                        foregroundColor:
                                            Theme.of(context).primaryColor,
                                        onTap: () => _createItem(item: item),
                                      )
                                    ],
                                    secondaryActions: [
                                      IconSlideAction(
                                          icon: Icons.delete,
                                          caption: 'Delete',
                                          color: Colors.transparent,
                                          foregroundColor: Colors.red,
                                          onTap: () => _onDelete(item, context))
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
                                            height: 5.h,
                                          ),
                                          Text('${item.qty} ${item.qtyType}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6!
                                                  .copyWith(
                                                    fontSize: 16.sp,
                                                  )),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      })
                    ],
                  );
          }),
      floatingActionButton: InkWell(
        onTap: () async {
          await _createItem();
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
    );
  }
}
