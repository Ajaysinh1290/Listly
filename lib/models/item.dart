class Item {
  late String itemId;
  late String title;
  late num price;
  late int qty;
  late String qtyType;
  late String currencySymbol;

  Item(
      {required this.itemId,
      required this.title,
      required this.price,
      required this.qty,
      required this.currencySymbol,
      required this.qtyType});

  Item.fromJson(Map<String, dynamic> data) {
    itemId = data['itemId'];
    title = data['title'];
    price = data['price'];
    qty = data['qty'];
    qtyType = data['qtyType'];
    currencySymbol = data['currencySymbol'];
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'title': title,
      'price': price,
      'qty': qty,
      'qtyType': qtyType,
      'currencySymbol': currencySymbol
    };
  }
}
