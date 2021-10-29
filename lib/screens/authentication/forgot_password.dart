import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/auth_controller.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: Constants.scaffoldPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80.w,
                ),
                Column(
                  children: [
                    Text(
                      'Forgot Password ?',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    SizedBox(
                      height: 15.w,
                    ),
                    Text(
                      'Enter the email address you used to create your account and we will email you a link to reset your password.',
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.h,
                ),
                MyTextField(
                  labelText: 'Email',
                  controller: authController.emailController,
                ),
                SizedBox(
                  height: 60.h,
                ),
                Obx(() => MyButton(
                      onPressed: () => authController.forgotPassword(),
                      buttonText: 'Send Mail',
                      isLoading: authController.isLoading.value,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
