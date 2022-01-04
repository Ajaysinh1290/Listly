import 'package:listly/utils/constants/list_type.dart';

class ListModel {
  late String listId;
  late String title;
  late DateTime createdOn;
  List<dynamic>? items;
  late String listType;

  ListModel(
      {required this.listId,
      required this.title,
      required this.createdOn,
      required this.listType,
      this.items});

  ListModel.fromJson(Map<String, dynamic> data) {
    listId = data['listId'];
    title = data['title'];
    createdOn = data['createdOn']?.toDate();
    items = data['items'];
    listType = data['listType'];
  }

  Map<String, dynamic> toJson() {
    return {
      'listId': listId,
      'title': title,
      'createdOn': createdOn,
      'items': items,
      'listType': listType
    };
  }
}
