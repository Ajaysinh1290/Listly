import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:listly/controllers/user_controller.dart';
import 'package:listly/models/user_model.dart';
import 'package:listly/screens/authentication/sign_up.dart';
import 'package:listly/screens/home/home_page.dart';
import 'package:listly/widgets/dialog/show_error_dialog.dart';
import 'package:listly/widgets/dialog/show_successful_dialog.dart';

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  static AuthController instance = Get.find();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  RxBool isLoading = false.obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    Rx<User?> firebaseUser = Rx<User?>(auth.currentUser);
    firebaseUser.bindStream(auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAll(const SignUp(), transition: Transition.size);
    } else {
      isLoading.value = true;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) {
        Get.find<UserController>().user = UserModel.fromJson(value.data()!);
      });
      Get.offAll(const HomePage(), transition: Transition.size);
      isLoading.value = false;
    }
  }

  bool _signUpValidation() {
    return userNameValidator() && emailValidator() && passwordValidator();
  }

  bool _signInValidation() {
    return emailValidator() && passwordValidator();
  }

  bool userNameValidator() {
    if (userNameController.text.trim().isEmpty) {
      showErrorDialog('Authentication Error', 'User name can\'t be empty.');
      return false;
    }
    return true;
  }

  bool emailValidator() {
    if (emailController.text.trim().isEmpty) {
      showErrorDialog('Authentication Error', 'Email address can\'t be empty.');
      return false;
    }
    return true;
  }

  bool passwordValidator() {
    if (passwordController.text.trim().isEmpty) {
      showErrorDialog('Authentication Error', 'Password can\'t be empty.');
      return false;
    }
    return true;
  }

  void forgotPassword() async {
    if (!emailValidator()) {
      return;
    }
    try {
      isLoading.value = true;
      await auth.sendPasswordResetEmail(email: emailController.text.trim());
      emailController.text = '';
      await showSuccessfulDialog('Sent Successfully',
          'Password reset link sent to your email address successfully !',
          onTap: () {
        Get.back();
        Get.back();
      });
    } on FirebaseAuthException catch (e) {
      showErrorDialog("Authentication Error", getMessageFromErrorCode(e));
    } catch (e) {
      debugPrint(e.toString());
      showErrorDialog("Authentication Error", e.toString());
    }
    isLoading.value = false;
  }

  void signIn() async {
    if (!_signInValidation()) {
      return;
    }
    try {
      isLoading.value = true;
      await auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      userNameController.text = '';
      emailController.text = '';
      passwordController.text = '';
    } on FirebaseAuthException catch (e) {
      showErrorDialog("Authentication Error", getMessageFromErrorCode(e));
    } catch (e) {
      debugPrint(e.toString());
      showErrorDialog("Authentication Error", e.toString());
    }
    isLoading.value = false;
  }

  Future<void> changeName() async {
    if (!userNameValidator()) {
      return;
    }
    isLoading.value = true;
    UserModel? user = Get.find<UserController>().user;
    user!.userName = userNameController.text.trim();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.userId)
        .set(user.toJson());
    Get.find<UserController>().user = UserModel.fromJson(user.toJson());
    userNameController.text = '';
    await showSuccessfulDialog(
        'Updated Successfully', 'User name has been updated successfully !',
        onTap: () {
      Get.back();
      Get.back();
    });
    isLoading.value = false;
  }

  void signUp() async {
    if (!_signUpValidation()) {
      return;
    }
    try {
      isLoading.value = true;
      await auth
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim())
          .then((result) async {
        debugPrint('User Id  :  ${result.user!.uid}');
        debugPrint('Email  :  ${result.user!.email}');
        UserModel userModel = UserModel(
            userId: result.user!.uid,
            userName: userNameController.text,
            email: result.user!.email!);
        userNameController.text = '';
        emailController.text = '';
        passwordController.text = '';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userModel.userId)
            .set(userModel.toJson());
      });
    } on FirebaseAuthException catch (e) {
      showErrorDialog("Authentication Error", getMessageFromErrorCode(e));
    } catch (e) {
      debugPrint(e.toString());
      showErrorDialog("Authentication Error", e.toString());
    }
    isLoading.value = false;
  }

  void changeEmail() async {
    if (!_signInValidation()) {
      return;
    }
    isLoading.value = true;
    try {
      AuthCredential credential = EmailAuthProvider.credential(
          email: Get.find<UserController>().user!.email,
          password: passwordController.text.trim());
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credential);
      await FirebaseAuth.instance.currentUser!
          .updateEmail(emailController.text.trim());

      UserModel? user = Get.find<UserController>().user;
      user!.email = emailController.text.trim();
      Get.find<UserController>().user = UserModel.fromJson(user.toJson());
      emailController.text = '';
      passwordController.text = '';
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.userId)
          .set(user.toJson());
      await showSuccessfulDialog('Sent Successfully',
          'Your Email Address has been updated successfully !', onTap: () {
        Get.back();
      });
    } on FirebaseAuthException catch (e) {
      showErrorDialog("Authentication Error", getMessageFromErrorCode(e));
    } catch (e) {
      debugPrint(e.toString());
      showErrorDialog("Authentication Error", e.toString());
    }
    isLoading.value = false;
  }

  void signOut() {
    UserController userController = Get.find();
    userController.clear();
    auth.signOut();
  }

  bool newPasswordValidation() {
    if (passwordController.text.trim().isEmpty) {
      showErrorDialog('Authentication Error', 'Old Password can\'t be empty.');
      return false;
    } else if (newPasswordController.text.trim().isEmpty) {
      showErrorDialog('Authentication Error', 'New Password can\'t be empty.');
      return false;
    }
    return true;
  }

  void changePassword() async {
    if (!newPasswordValidation()) {
      return;
    }
    isLoading.value = true;
    try {
      AuthCredential credential = EmailAuthProvider.credential(
          email: Get.find<UserController>().user!.email,
          password: passwordController.text.trim());
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credential);
      await FirebaseAuth.instance.currentUser!
          .updatePassword(newPasswordController.text.trim());

      passwordController.text = '';
      newPasswordController.text = '';
    } on FirebaseAuthException catch (e) {
      showErrorDialog("Authentication Error", getMessageFromErrorCode(e));
    } catch (e) {
      debugPrint(e.toString());
      showErrorDialog("Authentication Error", e.toString());
    }
    isLoading.value = false;
  }

  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.additionalUserInfo!.isNewUser) {
        UserModel userModel = UserModel(
            userId: userCredential.user!.uid,
            userName: userCredential.user!.displayName ?? '',
            profilePic: userCredential.user?.photoURL,
            email: userCredential.user!.email!);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userModel.userId)
            .set(userModel.toJson());
      }
    } catch (e) {
      debugPrint(e.toString());
      showErrorDialog("Authentication Error", e.toString());
    }
  }

  String getMessageFromErrorCode(FirebaseAuthException error) {
    switch (error.code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "Email already used.";
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Wrong password";
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "No user found with this email.";
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return "User disabled.";
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Too many requests to log into this account.";
      case "ERROR_OPERATION_NOT_ALLOWED":
        return "Server error, please try again later.";
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Email address is invalid.";
      default:
        return error.message ?? 'Login Failed. Please try again.';
    }
  }
}
