import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connuect/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  final String category;
  final int productCount;

  const ProductListScreen({
    Key? key,
    required this.category,
    this.productCount = 7,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<List<ProductItem>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _loadProducts();
  }

  Future<List<ProductItem>> _loadProducts() async {
    // Check the category to return predefined products
    if (widget.category == 'Clothing') {
      // Predefined products for Video 1
      return [
        ProductItem(
          name: 'Top',
          price: 29.99,
          category: 'Clothing',
          imageUrl: 'https://m.media-amazon.com/images/I/714g9aJ1dhL._SX679_.jpg',
        ),
        ProductItem(
          name: 'Pant',
          price: 49.99,
          category: 'Clothing',
          imageUrl: 'https://m.media-amazon.com/images/I/617ShTI4e5L._SY879_.jpg',
        ),
        ProductItem(
          name: 'Head scarf',
          price: 19.99,
          category: 'Clothing',
          imageUrl: 'https://m.media-amazon.com/images/I/71E0wq5TA-L._SX679_.jpg',
        ),
        ProductItem(
          name: 'Shoes',
          price: 89.99,
          category: 'Clothing',
          imageUrl: 'https://m.media-amazon.com/images/I/51nzsiPwwiL._SY695_.jpg',
        ),
        ProductItem(
          name: 'Hand bag',
          price: 59.99,
          category: 'Clothing',
          imageUrl: 'https://m.media-amazon.com/images/I/61uMB3+bJjL._SY695_.jpg',
        ),
        ProductItem(
          name: 'Glasses',
          price: 39.99,
          category: 'Clothing',
          imageUrl: 'https://m.media-amazon.com/images/I/51uNXJVfbeL._SX679_.jpg',
        ),
      ];
    } else if (widget.category == 'Food') {
      // Predefined products for Video 2
      return [
        ProductItem(
          name: 'Hibiscus',
          price: 5.99,
          category: 'Food',
          imageUrl: 'https://rukminim2.flixcart.com/image/832/832/xif0q/plant-sapling/t/y/r/yes-annual-yes-yellow-hibiscus028-small-1-grow-bag-evergreen-original-imah5s57knskwkdg.jpeg?q=70&crop=false 2x, https://rukminim2.flixcart.com/image/416/416/xif0q/plant-sapling/t/y/r/yes-annual-yes-yellow-hibiscus028-small-1-grow-bag-evergreen-original-imah5s57knskwkdg.jpeg?q=70&crop=false 1x',
        ),
        ProductItem(
          name: 'Curry leaves',
          price: 2.49,
          category: 'Food',
          imageUrl: 'https://cdn.grofers.com/cdn-cgi/image/f=auto,fit=scale-down,q=70,metadata=none,w=1800/app/images/products/sliding_image/17643a.jpg?ts=1690813684',
        ),
        ProductItem(
          name: 'Nellikai powder',
          price: 7.99,
          category: 'Food',
          imageUrl: 'https://m.media-amazon.com/images/I/71mXEhUWMYL._SY879_.jpg',
        ),
        ProductItem(
          name: 'Pure chili oil',
          price: 4.99,
          category: 'Food',
          imageUrl: 'https://m.media-amazon.com/images/I/61ubMhV+GDL._SX679_.jpg',
        ),
      ];
    }

    // If no predefined category matches, return an empty list or handle accordingly.
    return [];
  }

  Future<void> _addToCart(ProductItem product) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(uid)
          .collection('items')
          .add({
        'name': product.name,
        'category': product.category,
        'quantity': product.quantity,
        'price': product.price,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding to cart: $e')));
    }
  }

  int _totalCartItems(List<ProductItem> products) {
    return products.fold(0, (sum, item) => sum + item.quantity);
  }

  void _handleAddToCart(List<ProductItem> products) {
    for (var item in products) {
      if (item.quantity > 0) {
        _addToCart(item);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${_totalCartItems(products)} items to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${widget.category} Products'),
      ),
      body: FutureBuilder<List<ProductItem>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      '\$${product.price.toStringAsFixed(2)} • ${product.category}',
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (product.quantity > 0) product.quantity--;
                              });
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text(product.quantity.toString().padLeft(2, '0')),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                product.quantity++;
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<List<ProductItem>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final products = snapshot.data!;
          return Visibility(
            visible: _totalCartItems(products) > 0,
            child: GestureDetector(
              onTap: () => _handleAddToCart(products),
              child: Container(
                color: Colors.orange,
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'Add to cart (${_totalCartItems(products)})',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}