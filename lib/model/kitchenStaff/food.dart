import 'package:cloud_firestore/cloud_firestore.dart';

class Food {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String stallName;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stallName,
  });

  factory Food.fromDocument(DocumentSnapshot doc) {
    return Food(
      id: doc.id,
      name: doc['food_name'],
      description: doc['food_description'],
      price: (doc['food_price'] as num).toDouble(),
      imageUrl: doc['food_image_url'],
      stallName: doc['stall_name'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'food_name': name,
      'food_description': description,
      'food_price': price,
      'food_image_url': imageUrl,
      'stall_name': stallName,
    };
  }
}
