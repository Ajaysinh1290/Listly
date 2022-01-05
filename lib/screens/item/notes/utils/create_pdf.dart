import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:listly/models/items/notes.dart';
import 'package:listly/widgets/file/save_and_launch_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<void> createPdf(List<Note>? items, String title, String listId) async {
  PdfDocument document = PdfDocument();
  final page = document.pages.add();
  final ByteData data =
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final fontData =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  final Size pageSize = page.getClientSize();
  final PdfLayoutResult titleLayoutResult = PdfTextElement(
          text: title,
          font: PdfTrueTypeFont(fontData, 25, style: PdfFontStyle.bold),
          brush: PdfSolidBrush(PdfColor(0, 0, 0)))
      .draw(
          page: page,
          bounds: Rect.fromLTWH(
              0, 0, page.getClientSize().width, page.getClientSize().height),
          format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;

  String strData = '';
  double offsetY = titleLayoutResult.bounds.bottom + 30;
  if (items != null) {
    for (var item in items) {
      PdfLayoutResult strLayout = PdfTextElement(
              text: item.title,
              font: PdfTrueTypeFont(fontData, 20, style: PdfFontStyle.bold),
              brush: PdfSolidBrush(PdfColor(0, 0, 0)))
          .draw(
              page: page,
              bounds: Rect.fromLTWH(0, offsetY, page.getClientSize().width,
                  page.getClientSize().height),
              format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;
      strLayout = PdfTextElement(
              text: item.description??'',
              font: PdfTrueTypeFont(fontData, 18,
                  style: PdfFontStyle.regular),
              brush: PdfSolidBrush(PdfColor(0, 0, 0)))
          .draw(
              page: page,
              bounds: Rect.fromLTWH(0, strLayout.bounds.bottom + 10, page.getClientSize().width,
                  page.getClientSize().height),
              format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate))!;
      offsetY = strLayout.bounds.bottom + 20;
    }
  }

  List<int> bytes = document.save();
  document.dispose();

  saveAndLaunchFile(bytes, '$listId.pdf');
}
