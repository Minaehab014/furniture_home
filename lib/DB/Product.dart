class Product {
  final String id;
  final String image;
  final double price;
  final String description;
  final int quantity;
  final String category;
  final String subCategory;
  final String userId;
  final double sum_rating;
  final double cout_ratings;
  List<Map<String, dynamic>> rating;
  List<Map<String, dynamic>> comments;

  Product(
      {required this.id,
      required this.price,
      required this.description,
      required this.quantity,
      required this.category,
      required this.subCategory,
      required this.userId,
      required this.image,
      required this.sum_rating,
      required this.cout_ratings,
      required this.rating,
      required this.comments});
}
