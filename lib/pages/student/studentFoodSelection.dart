import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/student/cartProvider.dart';

class FoodMenu extends StatelessWidget {
  final String storeName;
  final String storeImage;
  final List<Map<String, dynamic>> foodItems;

  const FoodMenu({
    super.key,
    required this.storeName,
    required this.storeImage,
    required this.foodItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: Text(storeName),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.fromLTRB(8, 15, 8, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                storeImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                var foodItem = foodItems[index];
                var foodName = foodItem['food_name'];
                var foodPrice = foodItem['food_price'];
                var foodDescription = foodItem['food_description'];
                var foodImageUrl = foodItem['food_image_url'];
                var cartProvider = Provider.of<CartProvider>(context);
                var cartItems = cartProvider.cartItems;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                            color: Color.fromRGBO(122, 178, 178, 1),
                            width: 2.0,
                          ),
                        ),
                        leading: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromRGBO(122, 178, 178, 1),
                              width: 2.0,
                            ),
                            color: Colors.blueGrey[100],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              foodImageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          foodName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodDescription,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            ),
                            Text('RM ${foodPrice.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: cartItems.containsKey(foodName) &&
                                      cartItems[foodName]!['quantity'] > 0
                                  ? () {
                                      cartProvider.removeItem(foodName);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '$foodName removed from cart'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  : null,
                              color: cartItems.containsKey(foodName) &&
                                      cartItems[foodName]!['quantity'] > 0
                                  ? null
                                  : Colors.grey,
                            ),
                            Text(cartItems.containsKey(foodName)
                                ? '${cartItems[foodName]!['quantity']}'
                                : '0'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cartProvider.addItem(foodName, foodItem);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$foodName added to cart'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
