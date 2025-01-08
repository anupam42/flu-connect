import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/screens/profile_screen.dart';

class FoodItem {
  final String name;
  final double price;
  final int calories;
  final String imageUrl;
  int quantity; // quantity starts at 0 by default

  FoodItem({
    required this.name,
    required this.price,
    required this.calories,
    required this.imageUrl,
    this.quantity = 0,
  });
}

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Example data — in a real app, you might fetch this from a database.
  final List<FoodItem> _foodItems = List.generate(30, (index) {
    return FoodItem(
      name: 'Food Item #${index + 1}',
      price: 5.99 + index, // Increment price for variety
      calories: 50 + (index * 10), // Increment calories for variety
      imageUrl: 'https://via.placeholder.com/80x60.png?text=Food${index + 1}',
    );
  });

  // Add or update item in Firestore subcollection "carts/{uid}/items"
  Future<void> _addToCart(FoodItem food) async {
    try {
      String uid = _auth.currentUser!.uid;
      // For simplicity, we call `.add` each time
      // (could be updated to `.set` if you want to prevent duplicates).
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(uid)
          .collection('items')
          .add({
        'name': food.name,
        'quantity': food.quantity,
        'price': food.price,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $e')),
      );
    }
  }

  // Calculate total quantity for display in the bottom bar
  int get totalCartItems {
    return _foodItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Called when the user taps on bottom "View cart (#)" bar.
  void _handleViewCart() {
    // Loop through each FoodItem and add to Firestore if quantity > 0
    for (var item in _foodItems) {
      if (item.quantity > 0) {
        _addToCart(item);
      }
    }

    // (Optional) Navigate to ProfileScreen with Cart tab open
    // Just an example — adjust as needed for your route:
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          uid: _auth.currentUser!.uid,
          initialTabIndex: 1,
          // possibly pass an initialTabIndex param
        ),
      ),
    );

    // Provide feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cart updated! You have $totalCartItems items.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Foods'),
      ),
      body: ListView.builder(
        itemCount: _foodItems.length,
        itemBuilder: (context, index) {
          final foodItem = _foodItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Card(
              child: ListTile(
                leading: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    foodItem.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(foodItem.name),
                subtitle: Text('\$${foodItem.price.toStringAsFixed(2)} '
                    '• ${foodItem.calories} Cal'),
                // Instead of a single button, we create a row with - / quantity / +
                trailing: SizedBox(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (foodItem.quantity > 0) {
                              foodItem.quantity--;
                            }
                          });
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(foodItem.quantity.toString().padLeft(2, '0')),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            foodItem.quantity++;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  // Optionally do something when the tile is tapped
                },
              ),
            ),
          );
        },
      ),
      // Bottom bar shows only if totalCartItems > 0
      bottomNavigationBar: Visibility(
        visible: totalCartItems > 0,
        child: GestureDetector(
          onTap: _handleViewCart,
          child: Container(
            color: Colors.orange,
            height: 50,
            alignment: Alignment.center,
            child: Text(
              'View cart (${totalCartItems.toString()})',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
