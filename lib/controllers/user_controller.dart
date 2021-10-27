import 'package:get/get.dart';
import 'package:listly/models/user_model.dart';

class UserController extends GetxController {
  final Rx<UserModel?> _userModel = Rxn<UserModel?>();

  set user(UserModel? value) => _userModel.value = value;

  UserModel? get user => _userModel.value;

  void clear() {
    _userModel.value = null;
  }
}
