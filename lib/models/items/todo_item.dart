class TodoItem {
  late String itemId;
  late String title;
  late bool isDone;

  TodoItem(
      {required this.itemId,
        required this.title,
        required this.isDone
      });

  TodoItem.fromJson(Map<String, dynamic> data) {
    itemId = data['itemId'];
    title = data['title'];
    isDone = data['isDone'];
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'title': title,
      'isDone' : isDone
    };
  }
}
