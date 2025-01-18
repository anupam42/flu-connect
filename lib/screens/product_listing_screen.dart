import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connuect/api/pixabay_api.dart';
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
    // Fetch images for the category from Pixabay
    final imageUrls = await PixabayService.fetchImageUrls(
      widget.category.toLowerCase(),
      count: widget.productCount,
    );

    // Generate product items using fetched images
    return List.generate(widget.productCount, (index) {
      return ProductItem(
        name: '${widget.category} Item #${index + 1}',
        price: 10.0 + index, // Example pricing
        category: widget.category,
        imageUrl: imageUrls.isNotEmpty 
            ? imageUrls[index % imageUrls.length] 
            : '',
      );
    });
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
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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