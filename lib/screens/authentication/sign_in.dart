import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:listly/controllers/auth_controller.dart';
import 'package:listly/screens/authentication/sign_up.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/text-field/text_field.dart';
import 'forgot_password.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: Constants.scaffoldPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30.h,
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  'Hey,',
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  'Login Now.',
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Colors.grey.shade400),
                ),
                SizedBox(
                  height: 60.h,
                ),
                Column(
                  children: [
                    MyTextField(
                      labelText: 'Email',
                      controller: authController.emailController,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    MyTextField(
                      labelText: 'Password',
                      obscureText: true,
                      controller: authController.passwordController,
                    )
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {
                        Get.to(
                          const ForgotPassword(),
                        );
                      },
                      child: Text(
                        'Forgot Password ?',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      )),
                ),
                SizedBox(
                  height: 50.h,
                ),
                Obx(() {
                  return Column(
                    children: [
                      MyButton(
                          onPressed: () {
                            authController.signIn();
                          },
                          isLoading: authController.isLoading.value,
                          buttonText: 'Login'),
                    ],
                  );
                }),
                SizedBox(
                  height: 20.h,
                ),
                GestureDetector(
                  onTap: () => authController.signInWithGoogle(),
                  child: Container(
                    height: 80.h,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(
                            color: Colors.black.withOpacity(0.08), width: 1.2)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/google_icon.png',
                          width: 30.73.w,
                          height: 30.h,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          'Sign in with Google',
                          style: Theme.of(context).textTheme.headline4,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(60),
                ),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Don\'t have an account ?',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Colors.black.withOpacity(0.25),
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: () => Get.offAll(const SignUp()),
                        child: Text(
                          'Sign up',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
