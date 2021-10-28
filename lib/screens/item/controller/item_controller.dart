import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/item.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/utils/theme/color_palette.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';

class ItemController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController qtyTypeController = TextEditingController();
  final RxString _currencySymbol = RxString(Constants.currencySymbols.first);

  // final RxString _qtyType = RxString(Constants.qtyTypes.first);
  RxBool isLoading = RxBool(false);
  GlobalKey<FormState> formKey = GlobalKey();
  Item? _item;

  Item? get item => _item;
  final RxString _searchQuery = RxString('');

  String get searchQuery => _searchQuery.value;

  set searchQuery(String value) {
    _searchQuery.value = value;
  }

  set item(Item? item) {
    _item = item;
    if (item != null) {
      titleController.text = item.title;
      priceController.text = item.price.toString();
      qtyController.text = item.qty.toString();
      currencySymbol = item.currencySymbol;
      qtyTypeController.text = item.qtyType;
    }
  }

  set currencySymbol(String value) => _currencySymbol.value = value;

  String get currencySymbol => _currencySymbol.value;

  // set qtyType(String value) => _qtyType.value = value;

  // String get qtyType => _qtyType.value;

  String? validatePrice(value) {
    if (priceController.text.trim().isEmpty) {
      return 'Price can\'t be empty';
    } else {
      try {
        double.parse(priceController.text.trim());
      } on FormatException catch (_) {
        return 'Only numbers are allowed';
      }
    }
    return null;
  }

  String? validateQty(value) {
    if (qtyController.text.trim().isEmpty) {
      return 'Qty can\'t be empty';
    } else {
      try {
        int.parse(qtyController.text.trim());
      } on FormatException catch (_) {
        return 'Only numbers are allowed';
      }
    }
    return null;
  }

  String? validateTitle(value) {
    if (titleController.text.trim().isEmpty) {
      return 'Title can\'t be empty';
    }
    return null;
  }

  createItem(String listId) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      if (item == null) {
        await addItem(listId);
      } else {
        await updateItem(listId);
      }
      titleController.text = '';
      priceController.text = '';
      qtyController.text = '';
      isLoading.value = false;
      Get.back();
    }
  }

  addItem(String listId) async {
    String userId = Get.find<UserController>().user!.userId;
    item = Item(
        title: titleController.text,
        price: num.parse(priceController.text),
        currencySymbol: currencySymbol,
        itemId: DateTime.now().millisecondsSinceEpoch.toString(),
        qty: int.parse(qtyController.text),
        qtyType: qtyTypeController.text);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(item!.itemId)
        .set(item!.toJson());
  }

  updateItem(String listId) async {
    String userId = Get.find<UserController>().user!.userId;
    item!.title = titleController.text;
    item!.price = num.parse(priceController.text);
    item!.qty = int.parse(qtyController.text);
    item!.qtyType = qtyTypeController.text;
    item!.currencySymbol = currencySymbol;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(item!.itemId)
        .set(item!.toJson());
  }

  void onDeleteItem(Item item, String listId) async {
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
      animationDuration: const Duration(milliseconds: 500),
      titleText: Text(
        'Item Deleted Successfully',
        style: Theme.of(Get.context!)
            .textTheme
            .headline6!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      messageText: Text(
        item.title,
        style: Theme.of(Get.context!).textTheme.headline6,
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
          style: Theme.of(Get.context!).textTheme.headline6!.copyWith(
              fontWeight: FontWeight.bold, color: ColorPalette.yellow),
        ),
      ),
    );
  }

  onDecrement(Item item, String listId) async {
    item.qty -= 1;
    await _saveQty(item, listId);
  }

  onIncrement(Item item, String listId) async {
    item.qty += 1;
    await _saveQty(item, listId);
  }

  _saveQty(Item item, String listId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(Get.find<UserController>().user!.userId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(item.itemId)
        .set({'qty': item.qty}, SetOptions(merge: true));
  }

  createItemDialog(String listId, {Item? item}) {
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
                MyTextField(
                    labelText: 'Qty Type',
                    controller: itemController.qtyTypeController,
                    suffixIcon: PopupMenuButton(
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: 30.sp,
                        color: Colors.grey.shade700,
                      ),
                      onSelected: (String value) {
                        itemController.qtyTypeController.text = value;
                      },
                      itemBuilder: (BuildContext context) {
                        return Constants.qtyTypes
                            .map<PopupMenuItem<String>>((value) {
                          return PopupMenuItem(
                              child: Text(value,
                                  style: Theme.of(context).textTheme.headline6),
                              value: value);
                        }).toList();
                      },
                    )),
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
}
