import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:listly/models/item.dart';
import 'package:listly/models/list_model.dart';

class Temp extends StatelessWidget {
  final ValueNotifier<bool> isLoading = ValueNotifier(true);

  Temp({Key? key}) : super(key: key);

  doTask() async {
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) async {
      for (var element in value.docs) {
        String userId = element['userId'];
        debugPrint('user Id $userId');
        await fetchList(userId);
      }
    });
    isLoading.value = false;
  }

  fetchList(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .get()
        .then((value) async {
      for (var element in value.docs) {
        ListModel listModel = ListModel.fromJson(element.data());
        debugPrint('list model $listModel');
        listModel.items = await fetchItemsList(userId, listModel.listId);
        debugPrint('items added in list ${listModel.items}');
        await uploadListItems(userId, listModel);
        debugPrint('items added');
      }
    });
  }

  uploadListItems(String userId, ListModel listModel) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listModel.listId)
        .set(listModel.toJson());
  }

  fetchItemsList(String userId, String listId) async {
    List<String> items = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .get()
        .then((value) {
      for (var element in value.docs) {
        Item item = Item.fromJson(element.data());
        items.add(item.itemId);
      }
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    doTask();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temp Data'),
      ),
      body: ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (context, value, _) {
            return Center(
              child: value
                  ? const CircularProgressIndicator()
                  : const Text('Data successfully uploaded'),
            );
          }),
    );
  }
}
