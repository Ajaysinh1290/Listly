import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'list_type.dart';

class Constants {
  static final EdgeInsets scaffoldPadding =
      EdgeInsets.symmetric(vertical: 12.w, horizontal: 25.w);
  static final dateFormat = DateFormat("hh:mm a dd/MM/yyyy");
  static final onlyDateFormat = DateFormat("dd/MM/yyyy");

  static const List qtyTypes = [
    'Packet',
    'Bundle',
    'Bunch',
    'Box',
    'Carton',
    'Kilogram',
    'Gram',
    'Litre',
    'Millilitre',
  ];

  static const List currencySymbols = ['₹', '\$', '€', '£', '¥'];

  static const List listTypes = [
    ListType.orders,
    ListType.todos,
    ListType.notes
  ];
}
