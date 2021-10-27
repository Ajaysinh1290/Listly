import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final FormFieldValidator? validator;
  final bool? obscureText;
  final bool? expanded;
  final TextInputType? textInputType;
  final String? suffixText;
  late FocusNode? focusNode;
  final TextCapitalization? textCapitalization;
  final Function(String)? onChanged;
  final bool? enableInteractiveSelection;
  final List<TextInputFormatter>? inputFormatters;
  final bool? readOnly;
  final Widget? suffixIcon;
  final Color? color;
  final ValueNotifier<Color> _labelColor = ValueNotifier(Colors.grey);

  MyTextField(
      {Key? key,
      required this.labelText,
      this.controller,
      this.validator,
      this.expanded,
      this.obscureText,
      this.textInputType,
      this.suffixText,
      this.textCapitalization,
      this.focusNode,
      this.onChanged,
      this.readOnly,
      this.enableInteractiveSelection,
      this.color,
      this.inputFormatters,
      this.suffixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    focusNode = focusNode ?? FocusNode();
    focusNode!.addListener(() {
      _labelColor.value =
          (focusNode!.hasFocus) ? Colors.black : Colors.grey;
    });
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ScreenUtil().radius(15)),
      child: ValueListenableBuilder<Color>(
        valueListenable: _labelColor,
        builder: (BuildContext context, Color value, Widget? child) {
          return TextFormField(
            cursorColor: Theme.of(context).primaryColor,
            maxLines: expanded ?? false ? null : 1,
            validator: validator,
            readOnly: readOnly ?? false,
            inputFormatters: inputFormatters,
            textCapitalization:
                textCapitalization ?? TextCapitalization.sentences,
            autovalidateMode: AutovalidateMode.disabled,
            enableInteractiveSelection: enableInteractiveSelection ?? true,
            focusNode: focusNode,
            controller: controller,
            onChanged: onChanged,
            keyboardType: textInputType ?? TextInputType.name,
            obscureText: obscureText ?? false,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setHeight(20),
                    horizontal: ScreenUtil().setWidth(10)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.7), width: 1.2)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.2)),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.2)),
                suffixStyle: GoogleFonts.openSans(
                    fontSize: 22.sp,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500),
                suffixText: suffixText,
                suffixIcon: suffixIcon,
                labelText: labelText,
                labelStyle: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: value, fontWeight: FontWeight.normal)),
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: Colors.black, height: 1.8),
          );
        },
      ),
    );
  }
}
