class User {
  String id;
  String email;
  String username;
  int type; // user,vendor
  String profileurl;

  User(
      {required this.id,
      required this.email,
      required this.username,
      required this.type,
      required this.profileurl});
}
