class ProductItem {
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  int quantity;

  ProductItem({
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.quantity = 0,
  });
}