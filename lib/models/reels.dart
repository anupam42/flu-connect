import 'package:connuect/models/product.dart';

final List<List<ProductItem>> productsByReel = [
  // Products for reel at index 0 (Food items)
  List.generate(7, (index) {
    final foodImages = [
      'https://cdn.pixabay.com/photo/2016/03/05/19/02/hamburger-1238246_1280.jpg',
      'https://cdn.pixabay.com/photo/2017/06/05/14/33/burger-2378345_1280.jpg',
      'https://cdn.pixabay.com/photo/2018/03/28/12/31/food-3262763_1280.jpg',
      'https://cdn.pixabay.com/photo/2016/11/18/17/20/vegetables-1837208_1280.jpg',
      'https://cdn.pixabay.com/photo/2015/04/08/13/13/meal-712665_1280.jpg',
      'https://cdn.pixabay.com/photo/2017/03/27/14/56/fruit-2179254_1280.jpg',
      'https://cdn.pixabay.com/photo/2015/02/07/11/09/pasta-627084_1280.jpg',
    ];
    return ProductItem(
      name: 'Food Item #${index + 1}',
      price: 5.99 + index,
      category: 'Food',
      link: '',
      imageUrl: foodImages[index % foodImages.length],
    );
  }),

  // Products for reel at index 1 (Household items)
  List.generate(8, (index) {
    final householdImages = [
      'https://cdn.pixabay.com/photo/2017/08/10/07/32/house-2618348_1280.jpg',
      'https://cdn.pixabay.com/photo/2015/03/26/09/54/living-room-690317_1280.jpg',
      'https://cdn.pixabay.com/photo/2016/03/05/22/45/sink-1239196_1280.jpg',
      'https://cdn.pixabay.com/photo/2016/12/14/14/53/sofa-1907480_1280.jpg',
      'https://cdn.pixabay.com/photo/2014/04/03/11/51/coffee-311988_1280.jpg',
      'https://cdn.pixabay.com/photo/2017/01/31/16/28/apartment-2026398_1280.jpg',
      'https://cdn.pixabay.com/photo/2017/08/06/09/08/home-2589537_1280.jpg',
      'https://cdn.pixabay.com/photo/2018/06/11/18/56/living-room-3468166_1280.jpg',
    ];
    return ProductItem(
      name: 'Household Item #${index + 1}',
      price: 15.99 + index,
      category: 'Household',
      link: '',
      imageUrl: householdImages[index % householdImages.length],
    );
  }),

  // Products for reel at index 2 (Appliances)
  List.generate(6, (index) {
    final applianceImages = [
      'https://cdn.pixabay.com/photo/2016/11/29/05/08/appliance-1868735_1280.jpg',
      'https://cdn.pixabay.com/photo/2015/02/04/11/48/microwave-623363_1280.jpg',
      'https://cdn.pixabay.com/photo/2016/04/24/13/30/coffee-machine-1344774_1280.jpg',
      'https://cdn.pixabay.com/photo/2014/11/24/16/53/toaster-545619_1280.jpg',
      'https://cdn.pixabay.com/photo/2016/11/29/09/08/kettle-1869268_1280.jpg',
      'https://cdn.pixabay.com/photo/2018/09/11/21/11/kettle-3679852_1280.jpg',
    ];
    return ProductItem(
      name: 'Appliance #${index + 1}',
      price: 99.99 + (index * 20),
      category: 'Appliance',
      link:'',
      imageUrl: applianceImages[index % applianceImages.length],
    );
  }),

  // Products for reel at index 3 (Groceries)
  List.generate(5, (index) {
    final groceryImages = [
      'https://cdn.pixabay.com/photo/2014/12/21/23/28/vegetables-575797_1280.jpg',
      'https://cdn.pixabay.com/photo/2016/10/25/12/28/apples-1763945_1280.jpg',
      'https://cdn.pixabay.com/photo/2014/04/22/02/56/fruit-329155_1280.jpg',
      'https://cdn.pixabay.com/photo/2015/04/08/13/13/meal-712665_1280.jpg',
      'https://cdn.pixabay.com/photo/2017/01/22/17/33/market-2002439_1280.jpg',
    ];
    return ProductItem(
      name: 'Grocery Item #${index + 1}',
      price: 3.49 + index,
      category: 'Groceries',
      link: '',
      imageUrl: groceryImages[index % groceryImages.length],
    );
  }),

  // Products for reel at index 4 (Electronics)
  List.generate(4, (index) {
    final electronicsImages = [
      'https://cdn.pixabay.com/photo/2015/01/21/14/14/macbook-606592_1280.jpg',
      'https://cdn.pixabay.com/photo/2015/05/15/14/14/apple-watch-768942_1280.jpg',
      'https://cdn.pixabay.com/photo/2016/05/05/02/37/computer-1376060_1280.jpg',
      'https://cdn.pixabay.com/photo/2017/01/16/19/54/keyboard-1981950_1280.jpg',
    ];
    return ProductItem(
      name: 'Electronic Item #${index + 1}',
      price: 199.99 + (index * 50),
      category: 'Electronics',
      link: '',
      imageUrl: electronicsImages[index % electronicsImages.length],
    );
  }),

  // Products for reel at index 5 (Clothing)
  List.generate(6, (index) {
    final clothingImages = [
      'https://cdn.pixabay.com/photo/2015/07/27/20/16/jacket-863586_1280.jpg',
      'https://cdn.pixabay.com/photo/2015/08/04/11/25/clothes-875610_1280.jpg',
      'https://cdn.pixabay.com/photo/2016/10/29/09/08/t-shirt-1785071_1280.jpg',
      'https://cdn.pixabay.com/photo/2016/06/02/18/02/woman-1439962_1280.jpg',
      'https://cdn.pixabay.com/photo/2015/07/27/20/18/shoes-863658_1280.jpg',
      'https://cdn.pixabay.com/photo/2014/12/11/17/36/trousers-565072_1280.jpg',
    ];
    return ProductItem(
      name: 'Clothing Item #${index + 1}',
      price: 29.99 + (index * 10),
      category: 'Clothing',
      link: 'https://amzn.in/d/iSpibts',
      imageUrl: clothingImages[index % clothingImages.length],
    );
  }),
];