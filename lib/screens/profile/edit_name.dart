import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:listly/controllers/auth_controller.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';

class EditName extends StatelessWidget {
  const EditName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    authController.userNameController.text =
        Get.find<UserController>().user!.userName;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Name'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: Constants.scaffoldPadding,
            child: Column(
              children: [
                SizedBox(
                  height: 20.h,
                ),
                MyTextField(
                  labelText: 'User Name',
                  controller: authController.userNameController,
                ),
                SizedBox(
                  height: 30.h,
                ),
                Obx(() {
                  return MyButton(
                    isLoading: authController.isLoading.value,
                    onPressed: () {
                      authController.changeName();
                    },
                    buttonText: 'Update Name',
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
