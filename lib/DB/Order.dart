class Order {
  final String id;
  final String userid;
  List<Map<String, dynamic>> productsid;
  int state;
  List<Map<String, dynamic>> vendorsList; // 0->send, 1->shipping , 2->deliverd
  Order(
      {required this.id,
      required this.productsid,
      required this.userid,
      required this.state,
      required this.vendorsList});
}
