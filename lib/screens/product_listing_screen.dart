import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connuect/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    if (widget.category == 'Clothing') {
      return [
        ProductItem(
          name: 'Top',
          price: 29.99,
          category: 'Clothing',
          link: 'https://amzn.in/d/iSpibts',
          imageUrl:
              'https://m.media-amazon.com/images/I/714g9aJ1dhL._SX679_.jpg',
        ),
        ProductItem(
          name: 'Pant',
          price: 49.99,
          category: 'Clothing',
          link: 'https://amzn.in/d/cOuux8P',
          imageUrl:
              'https://m.media-amazon.com/images/I/617ShTI4e5L._SY879_.jpg',
        ),
        ProductItem(
          name: 'Head scarf',
          price: 19.99,
          category: 'Clothing',
          link: 'https://amzn.in/d/2HTnlFl',
          imageUrl:
              'https://m.media-amazon.com/images/I/71E0wq5TA-L._SX679_.jpg',
        ),
        ProductItem(
          name: 'Shoes',
          price: 89.99,
          category: 'Clothing',
          link: 'https://amzn.in/d/7mlhpQ2',
          imageUrl:
              'https://m.media-amazon.com/images/I/51nzsiPwwiL._SY695_.jpg',
        ),
        ProductItem(
          name: 'Hand bag',
          price: 59.99,
          category: 'Clothing',
          link: 'https://amzn.in/d/9Z0oEMT',
          imageUrl:
              'https://m.media-amazon.com/images/I/61uMB3+bJjL._SY695_.jpg',
        ),
        ProductItem(
          name: 'Glasses',
          price: 39.99,
          category: 'Clothing',
          link: 'https://amzn.in/d/iKIh8ww',
          imageUrl:
              'https://m.media-amazon.com/images/I/51uNXJVfbeL._SX679_.jpg',
        ),
      ];
    } else if (widget.category == 'Food') {
      return [
        ProductItem(
          name: 'Hibiscus',
          price: 5.99,
          category: 'Food',
          link: 'https://dl.flipkart.com/s/CHGFf0NNNN',
          imageUrl:
              'https://rukminim2.flixcart.com/image/832/832/xif0q/plant-sapling/t/y/r/yes-annual-yes-yellow-hibiscus028-small-1-grow-bag-evergreen-original-imah5s57knskwkdg.jpeg?q=70&crop=false',
        ),
        ProductItem(
          name: 'Curry leaves',
          price: 2.49,
          category: 'Food',
          link: 'https://blinkit.com/prn/x/prid/17643',
          imageUrl:
              'https://cdn.grofers.com/cdn-cgi/image/f=auto,fit=scale-down,q=70,metadata=none,w=1800/app/images/products/sliding_image/17643a.jpg?ts=1690813684',
        ),
        ProductItem(
          name: 'Nellikai powder',
          price: 7.99,
          category: 'Food',
          link: 'https://amzn.in/d/bEHk6DM',
          imageUrl:
              'https://m.media-amazon.com/images/I/71mXEhUWMYL._SY879_.jpg',
        ),
        ProductItem(
          name: 'Pure chili oil',
          price: 4.99,
          category: 'Food',
          link: 'https://amzn.in/d/6QgsNIjs',
          imageUrl:
              'https://m.media-amazon.com/images/I/61ubMhV+GDL._SX679_.jpg',
        ),
      ];
    } else if (widget.category == 'Books') {
      return [
        ProductItem(
          name: 'Book 1',
          price: 14.99,
          category: 'Books',
          link: 'https://amzn.in/d/9gjCbjH',
          imageUrl:
              'https://m.media-amazon.com/images/I/81ehPIYaL5L._SY522_.jpg',
        ),
        ProductItem(
          name: 'Book 2',
          price: 44.69,
          category: 'Books',
          link: 'https://amzn.in/d/43sK7I4',
          imageUrl:
              'https://m.media-amazon.com/images/I/719HBHsXGmL._SY522_.jpg',
        ),
        ProductItem(
          name: 'Book 3',
          price: 411.77,
          category: 'Books',
          link: 'https://amzn.in/d/0E5ASrL',
          imageUrl:
              'https://m.media-amazon.com/images/I/71tMl8w0dWL._SY522_.jpg',
        ),
      ];
    } else if (widget.category == 'Blog') {
      return [
        ProductItem(
          name: 'Blog',
          price: 0.00,
          category: 'Blog',
          link: 'https://beacons.ai/kalash.rajvansh',
          imageUrl:
              'https://cdn.beacons.ai/profile_pictures/youtube/kalash.rajvansh?q=1734337973.810663',
        ),
      ];
    } else if (widget.category == 'Hotels') {
      return [
        ProductItem(
          name: 'Hotels',
          price: 0.00,
          category: 'Hotels',
          link: 'https://g.co/kgs/2CDgP6C',
          imageUrl:
              'https://pix8.agoda.net/hotelImages/32843669/0/13ce5392563e8be65271920b32082b63.jpeg',
        ),
      ];
    }
    return [];
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
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
        'imageUrl': product.imageUrl, // Save imageUrl
        'link': product.link, // Save product link
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding to cart: $e')));
    }
  }

  int _totalCartItems(List<ProductItem> products) {
    // ignore: avoid_types_as_parameter_names
    return products.fold(0, (sum, item) => sum + item.quantity);
  }

  void _handleAddToCart(List<ProductItem> products) {
    for (var item in products) {
      if (item.quantity > 0) {
        _addToCart(item);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Added ${_totalCartItems(products)} items to cart!')),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.price <= 0) ...[
                          GestureDetector(
                            onTap: () => _launchURL(product.link),
                            child: const Text(
                              'View Product',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ] else ...[
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _launchURL(product.link),
                            child: const Text(
                              'View Product',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ]
                      ],
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
