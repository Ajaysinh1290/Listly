class Note {
  late String itemId;
  late String title;
  String? description;

  Note(
      {required this.itemId,
        required this.title,
        this.description
      });

  Note.fromJson(Map<String, dynamic> data) {
    itemId = data['itemId'];
    title = data['title'];
    description = data['description'];
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'title': title,
      'description' : description
    };
  }
}
