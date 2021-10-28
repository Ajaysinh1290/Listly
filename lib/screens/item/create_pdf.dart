import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:listly/models/item.dart';
import 'package:listly/screens/item/save_and_launch_file.dart';
import 'package:listly/utils/constants/constants.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<void> createPdf(List<Item>? items, String title,String listId) async {
  PdfDocument document = PdfDocument();
  final page = document.pages.add();
  final ByteData data =
  await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  final fontData =
  data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  final Size pageSize = page.getClientSize();
  page.graphics.drawString(title, PdfTrueTypeFont(fontData, 30),
      bounds: Rect.fromLTWH(0, 20, pageSize.width - 200, 100));
  page.graphics.drawString(
    'Date : ' + Constants.onlyDateFormat.format(DateTime.now()),
    PdfTrueTypeFont(
      fontData,
      22,
    ),
    bounds: Rect.fromLTWH(pageSize.width - 180, 25, pageSize.width, 40),
  );

  PdfGrid grid = PdfGrid();

  grid.style = PdfGridStyle(
    font: PdfTrueTypeFont(fontData, 22),
    cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2),
  );
  grid.columns.add(count: 4);
  grid.columns[0].width = 40;
  grid.columns[1].width = 250;
  grid.headers.add(1);

  PdfGridRow header = grid.headers[0];
  header.cells[0].value = '';
  header.cells[1].value = 'Item';
  header.cells[2].value = 'Price';
  header.cells[3].value = 'Qty';

  if (items != null) {
    for (int i = 0; i < items.length; i++) {
      Item item = items[i];
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = (i + 1).toString();
      row.cells[1].value = item.title;
      row.cells[2].value = '${item.price} ${item.currencySymbol}';
      row.cells[3].value = item.qty.toString() + ' ' + item.qtyType;
    }
  }
  for (int i = 0; i < grid.rows.count; i++) {
    final PdfGridRow row = grid.rows[i];
    for (int j = 0; j < row.cells.count; j++) {
      final PdfGridCell cell = row.cells[j];
      if (j == 0) {
        cell.stringFormat.alignment = PdfTextAlignment.center;
      }
      cell.style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
  }
  grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 110, pageSize.width, pageSize.height));
  List<int> bytes = document.save();
  document.dispose();

  saveAndLaunchFile(bytes, '$listId.pdf');
}