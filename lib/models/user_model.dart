class UserModel {
  late String userId;
  late String userName;
  late String email;
  String? profilePic;

  UserModel(
      {required this.userId,
      required this.userName,
      required this.email,
      this.profilePic});

  UserModel.fromJson(Map<String, dynamic> data) {
    userId = data['userId'];
    userName = data['userName'];
    profilePic = data['profilePic'];
    email = data['email'];
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'profilePic': profilePic,
      'email': email,
    };
  }
}
