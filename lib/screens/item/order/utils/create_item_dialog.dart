import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listly/models/list_model.dart';
import 'package:listly/screens/item/order/controller/order_item_controller.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';
import 'package:get/get.dart';
import 'package:listly/models/items/order_item.dart';

createItemDialog(ListModel listModel, {OrderItem? item}) {
  OrderItemController itemController = Get.find();
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
                textInputType: TextInputType.number,
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
                    await itemController.createItem(listModel);
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