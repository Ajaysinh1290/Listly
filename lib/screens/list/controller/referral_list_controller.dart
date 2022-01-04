import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReferralListController extends GetxController {
  FocusNode searchFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController();
  final RxString _searchQuery = RxString('');

  String get searchQuery => _searchQuery.value;

  set searchQuery(String value) {
    _searchQuery.value = value;
  }
}
