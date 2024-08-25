import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/student/cartProvider.dart';
import 'studentFoodSelection.dart';
import 'cart.dart';

class StudentStorePage extends StatefulWidget {
  const StudentStorePage({super.key});

  @override
  _StudentStorePageState createState() => _StudentStorePageState();
}

class _StudentStorePageState extends State<StudentStorePage> {
  String searchKeyword = '';
  late Map<String, Map<String, dynamic>> stalls;
  List<String> displayedStalls = [];

  @override
  void initState() {
    super.initState();
    stalls = {};
    _fetchStalls();
  }

  void _fetchStalls() {
    FirebaseFirestore.instance.collection('stalls').get().then((stallsSnapshot) {
      for (var stallDoc in stallsSnapshot.docs) {
        var stallData = stallDoc.data();
        var stallName = stallData['stall_name'];
        var stallImageUrl = stallData['stall_image_url'];

        FirebaseFirestore.instance
            .collection('foods')
            .where('stall_name', isEqualTo: stallName)
            .get()
            .then((foodsSnapshot) {
          setState(() {
            List<Map<String, dynamic>> foodsList = [];
            for (var foodDoc in foodsSnapshot.docs) {
              var foodData = foodDoc.data();
              foodsList.add(foodData);
            }
            stalls[stallName] = {
              'foods': foodsList,
              'stall_image_url': stallImageUrl
            };
            displayedStalls = stalls.keys.toList();
            displayedStalls.sort(); // Sort stalls alphabetically
          });
        });
      }
    });
  }

  void _toggleCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudentCartPage(),
      ),
    );
  }

  void _updateDisplayedStalls() {
    setState(() {
      if (searchKeyword.isEmpty) {
        displayedStalls = stalls.keys.toList();
      } else {
        displayedStalls = stalls.keys
            .where((stallName) =>
            stallName.toLowerCase().contains(searchKeyword.toLowerCase()))
            .toList();
      }
      displayedStalls.sort(); // Sort stalls alphabetically
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Store List"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: _toggleCart,
                icon: const Icon(Icons.shopping_cart),
              ),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  int totalCartQuantity = cart.cartItems.values
                      .fold(0, (int sum, item) => item['quantity'] + sum);
                  return totalCartQuantity > 0
                      ? Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$totalCartQuantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                      : Container();
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
            child: TextField(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                suffixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                hintText: 'Search',
              ),
              style: const TextStyle(color: Colors.black),
              onChanged: (value) {
                setState(() {
                  searchKeyword = value;
                  _updateDisplayedStalls();
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemCount: displayedStalls.length,
              itemBuilder: (context, index) {
                var stallName = displayedStalls[index];
                var stallData = stalls[stallName]!;
                var stallImage = stallData['stall_image_url'];
                var stallFoods = stallData['foods'];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodMenu(
                            storeName: stallName,
                            storeImage: stallImage,
                            foodItems: stallFoods,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(122, 178, 178, 1),
                          width: 2.0,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: stallImage,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              stallName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
