  import 'package:connect/models/product.dart';

  final List<List<ProductItem>> productsByReel = [
    // Products for reel at index 0 (e.g., Food items)
    List.generate(7, (index) => ProductItem(
      name: 'Food Item #${index + 1}',
      price: 5.99 + index,
      category: 'Food',
      imageUrl: 'https://via.placeholder.com/80x60.png?text=Food${index + 1}',
    )),

    // Products for reel at index 1 (e.g., Household items)
    List.generate(8, (index) => ProductItem(
      name: 'Household Item #${index + 1}',
      price: 15.99 + index,
      category: 'Household',
      imageUrl: 'https://via.placeholder.com/80x60.png?text=Household${index + 1}',
    )),

    // Products for reel at index 2 (e.g., Appliances)
    List.generate(6, (index) => ProductItem(
      name: 'Appliance #${index + 1}',
      price: 99.99 + (index * 20),
      category: 'Appliance',
      imageUrl: 'https://via.placeholder.com/80x60.png?text=Appliance${index + 1}',
    )),

    // Products for reel at index 3 (e.g., Groceries)
    List.generate(5, (index) => ProductItem(
      name: 'Grocery Item #${index + 1}',
      price: 3.49 + index,
      category: 'Groceries',
      imageUrl: 'https://via.placeholder.com/80x60.png?text=Grocery${index + 1}',
    )),

    // Products for reel at index 4 (e.g., Electronics)
    List.generate(4, (index) => ProductItem(
      name: 'Electronic Item #${index + 1}',
      price: 199.99 + (index * 50),
      category: 'Electronics',
      imageUrl: 'https://via.placeholder.com/80x60.png?text=Electronic${index + 1}',
    )),

    // Products for reel at index 5 (e.g., Clothing)
    List.generate(6, (index) => ProductItem(
      name: 'Clothing Item #${index + 1}',
      price: 29.99 + (index * 10),
      category: 'Clothing',
      imageUrl: 'https://via.placeholder.com/80x60.png?text=Clothing${index + 1}',
    )),
  ];