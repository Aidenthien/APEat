import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../view_model/student/cartProvider.dart';
import 'studentMain.dart';

class StudentCartPage extends StatelessWidget {
  const StudentCartPage({super.key});

  Future<void> saveOrderToFirebase(
      Map<String, Map<String, dynamic>> orderItems, String userId) async {
    final ordersCollection = FirebaseFirestore.instance.collection('orders');
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm');
    final date = dateFormat.format(now);
    final time = timeFormat.format(now);

    for (var entry in orderItems.entries) {
      final foodName = entry.key;
      final foodData = entry.value;
      await ordersCollection.add({
        'date': date,
        'time': time,
        'order_status': false,
        'feedback_status': false,
        'quantity': foodData['quantity'],
        'tp_number': userId,
        'stall_name': foodData['stall_name'],
        'food_description': foodData['description'],
        'food_price': foodData['price'],
        'food_title': foodName,
      });
    }
  }

  Future<double> fetchAPCardBalance(String userId) async {
    final studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(userId)
        .get();

    if (studentDoc.exists) {
      return studentDoc.data()?['balance']?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  Future<void> updateAPCardBalance(String userId, double newBalance) async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(userId)
        .update({'balance': newBalance});
  }

  void showOrderPlacedDialog(BuildContext context, double newBalance) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Order Placed"),
          content: Text(
            "Your order has been placed successfully. New APCard balance: RM ${newBalance.toStringAsFixed(2)}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        const StudentMainPage(initialIndex: 2),
                  ),
                );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('No user logged in.'));
    }

    String userEmail = user.email!;
    String userId = userEmail.split('@').first; // Extract ID from email

    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Cart"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          var cartItems = cart.cartItems;

          if (cartItems.isEmpty) {
            return const Center(
              child: Text("Your cart is empty."),
            );
          }

          return FutureBuilder<double>(
            future:
                fetchAPCardBalance(userId), // Use userId for fetching balance
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              double apCardBalance = snapshot.data!;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var foodName = cartItems.keys.elementAt(index);
                        var foodData = cartItems[foodName]!;

                        return Padding(
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
                                  foodData['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(foodName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price: RM ${foodData['price'].toStringAsFixed(2)}',
                                ),
                                Text(
                                  'Quantity: ${foodData['quantity']}',
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    cart.removeItem(foodName);
                                  },
                                ),
                                Text('${foodData['quantity']}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    cart.addItem(foodName, foodData);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Color.fromRGBO(122, 178, 178, 1),
                          width: 2.0,
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            child: ListTile(
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                  color: Color.fromRGBO(122, 178, 178, 1),
                                  width: 2.0,
                                ),
                              ),
                              leading: const Text(
                                'APCard Balance',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                'RM ${apCardBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Quantity',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                cart.getTotalCartQuantity().toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Price',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'RM ${cart.getTotalCartPrice().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            double totalPrice = cart.getTotalCartPrice();
                            if (apCardBalance >= totalPrice) {
                              var orderItems =
                                  Map<String, Map<String, dynamic>>.from(
                                      cart.cartItems);
                              await saveOrderToFirebase(orderItems, userId);
                              double newBalance = apCardBalance - totalPrice;
                              await updateAPCardBalance(userId, newBalance);
                              showOrderPlacedDialog(
                                  context, newBalance); // Show the alert dialog
                              cart.clearCart();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Insufficient balance in APCard."),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(77, 134, 156, 1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 30.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text("Place Order"),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
