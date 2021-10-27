class ListModel {
  late String listId;
  late String title;
  late DateTime createdOn;

  ListModel({required this.listId, required this.title, required this.createdOn});

  ListModel.fromJson(Map<String, dynamic> data) {
    listId = data['listId'];
    title = data['title'];
    createdOn = data['createdOn']?.toDate();
  }

  Map<String, dynamic> toJson() {
    return {'listId': listId, 'title': title, 'createdOn': createdOn};
  }
}
