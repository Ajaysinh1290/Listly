import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImage(ImageSource source) async {
  var pickedFile =
      await ImagePicker().pickImage(source: source, imageQuality: 20);
  if (pickedFile != null) {
    return File(pickedFile.path);
  } else {
    debugPrint('no image selected');
  }
}
