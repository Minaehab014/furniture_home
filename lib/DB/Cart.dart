class Cart {
  final String id;
  final String userid;
  final String vendorid;
  final String productid;
  int quantity;
  Cart(
      {required this.id,
      required this.userid,
      required this.vendorid,
      required this.productid,
      required this.quantity});
}
