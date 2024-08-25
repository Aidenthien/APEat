import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:APEat/pages/kitchenStaff/kitchenAddFood.dart';
import 'package:APEat/pages/kitchenStaff/kitchenEditFood.dart';
import 'package:APEat/model/kitchenStaff/food.dart';

class KitchenMenu extends StatelessWidget {
  final String stallName;

  const KitchenMenu({Key? key, required this.stallName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Menu"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KitchenAddFood(stallName: stallName)),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10), // Small gap between AppBar and banner image
                FutureBuilder<QuerySnapshot>(
                  future: _firestore.collection('stalls').where('stall_name', isEqualTo: stallName).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No banner available"));
                    }

                    final stallData = snapshot.data!.docs.first;
                    final imageUrl = stallData['stall_image_url'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0), // Match the card margin
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 160, // Adjust the height of the banner image box here
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(77, 134, 156, 1),
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('foods')
                .where('stall_name', isEqualTo: stallName) // Filter by stallName
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text("Error fetching foods")),
                );
              }

              final foods = snapshot.data?.docs ?? [];

              if (foods.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text("No foods available")),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final foodDoc = foods[index];
                    final food = Food.fromDocument(foodDoc); // Ensure Food.fromDocument exists

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          color: Color.fromRGBO(122, 178, 178, 1),
                          width: 2.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(food.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    food.description,
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    '\RM${food.price.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => KitchenEditFood(food: food),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: foods.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
