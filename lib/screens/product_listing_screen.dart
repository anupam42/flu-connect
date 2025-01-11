import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  final List<ProductItem> productItems;
  const ProductListScreen({Key? key, required this.productItems}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addToCart(ProductItem product) async {
    try {
      String uid = _auth.currentUser!.uid;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e')),
      );
    }
  }

  int get totalCartItems {
    return widget.productItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void _handleAddToCart() {
    for (var item in widget.productItems) {
      if (item.quantity > 0) {
        _addToCart(item);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${totalCartItems} items to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Products'),
      ),
      body: widget.productItems.isEmpty 
          ? Center(child: Text('No products available for this reel.'))
          : ListView.builder(
              itemCount: widget.productItems.length,
              itemBuilder: (context, index) {
                final product = widget.productItems[index];
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
                                  if (product.quantity > 0) {
                                    product.quantity--;
                                  }
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
            ),
      bottomNavigationBar: Visibility(
        visible: totalCartItems > 0,
        child: GestureDetector(
          onTap: _handleAddToCart,
          child: Container(
            color: Colors.orange,
            height: 50,
            alignment: Alignment.center,
            child: Text(
              'Add to cart (${totalCartItems.toString()})',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}