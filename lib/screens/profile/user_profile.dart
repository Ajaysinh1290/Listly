import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:listly/models/user_model.dart';
import 'package:listly/screens/profile/edit_name.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:listly/utils/theme/color_palette.dart';
import 'package:listly/widgets/button/my_button.dart';
import 'package:listly/widgets/dialog/show_error_dialog.dart';

import 'edit_email.dart';
import 'edit_password.dart';
import 'image/full_image.dart';
import 'image/pick_image.dart';

class UserProfile extends StatelessWidget {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  UserProfile({Key? key}) : super(key: key);

  uploadProfilePic(ImageSource source, UserModel user) async {
    File? file = await pickImage(source);
    if (file != null) {
      try {
        _isLoading.value = true;
        await FirebaseStorage.instance
            .ref('users/' + user.userId + ".jpg")
            .putData(await file.readAsBytes(),
                SettableMetadata(contentType: 'image/jpeg'))
            .then((storage) async {
          String imageUrl = await storage.ref.getDownloadURL();

          user.profilePic = imageUrl;
          Get.find<UserController>().user = UserModel.fromJson(user.toJson());
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.userId)
              .set(user.toJson());
        });
      } on FirebaseException catch (_) {
        showErrorDialog("Error", "Error in uploading image to server");
      } catch (e) {
        showErrorDialog(
            "Error", "Error in uploading image to server\n${e.toString()}");
      }
      _isLoading.value = false;
      Get.back();
    }
  }

  _onEditButtonTap(UserModel user) {
    Get.bottomSheet(Container(
      margin: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.white,
      ),
      child: ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, value, _) {
            return value
                ? Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Text(
                      'Uploading Profile Photo...',
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.yellow),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                      if (user.profilePic != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.back();
                                Get.to(FullImage(
                                    imageUrl: user.profilePic!,
                                    heroTag: user.profilePic!));
                              },
                              child: SizedBox(
                                width: double.infinity,
                                height: 40.h,
                                child: Text(
                                  'View Photo',
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .headline6,
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
                          ],
                        ),
                      InkWell(
                        onTap: () async {
                          await uploadProfilePic(ImageSource.gallery, user);
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 40.h,
                          child: Text(
                            'Choose Photo From Gallery',
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
                          await uploadProfilePic(ImageSource.camera, user);
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 40.h,
                          child: Text(
                            'Click a Photo',
                            style: Theme.of(Get.context!).textTheme.headline6,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      )
                    ],
                  );
          }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    UserController userController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() {
            return Padding(
              padding: Constants.scaffoldPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40.h,
                  ),
                  GestureDetector(
                    onTap: () => _onEditButtonTap(userController.user!),
                    child: Center(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15.r),
                            child: userController.user!.profilePic != null
                                ? Hero(
                                    tag: userController.user!.profilePic!,
                                    child: Image.network(
                                      userController.user!.profilePic!,
                                      width: 140.w,
                                      height: 140.w,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    color: Theme.of(context).primaryColor,
                                    width: 140.w,
                                    height: 140.w,
                                    child: Icon(
                                      Icons.person,
                                      size: 40.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 5.w,
                            right: 5.w,
                            child: Container(
                              width: 30.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 18.sp,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'User Name',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Get.to(const EditName()),
                        child: Text(
                          'Edit',
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: Colors.black,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  Text(
                    userController.user!.userName,
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Email',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Get.to(const EditEmail()),
                        child: Text(
                          'Edit',
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: Colors.black,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  Text(
                    userController.user!.email,
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Password',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Get.to(const EditPassword()),
                        child: Text(
                          'Edit',
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: Colors.black,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  Text(
                    '********',
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  MyButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      buttonText: 'Logout')
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
