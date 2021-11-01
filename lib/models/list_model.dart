class ListModel {
  late String listId;
  late String title;
  late DateTime createdOn;
  List<dynamic>? items;

  ListModel(
      {required this.listId,
      required this.title,
      required this.createdOn,
      this.items});

  ListModel.fromJson(Map<String, dynamic> data) {
    listId = data['listId'];
    title = data['title'];
    createdOn = data['createdOn']?.toDate();
    items = data['items'];
  }

  Map<String, dynamic> toJson() {
    return {
      'listId': listId,
      'title': title,
      'createdOn': createdOn,
      'items': items
    };
  }
}
