import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../model/kitchenStaff/food.dart';

class KitchenFoodViewModel extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<String> _uploadImage(File image) async {
    final storageRef = _storage.ref().child('food_images').child('${DateTime.now().toIso8601String()}.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> addFood({
    required String name,
    required String description,
    required double price,
    required String stallName,
    required File image,
  }) async {
    _setSaving(true);

    try {
      final imageUrl = await _uploadImage(image);
      final food = Food(
        id: '',
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        stallName: stallName,
      );

      await _firestore.collection('foods').add(food.toFirestore());
    } finally {
      _setSaving(false);
    }
  }

  Future<void> updateFood(Food food, File? newImage) async {
    _setSaving(true);

    try {
      String imageUrl = food.imageUrl;
      if (newImage != null) {
        imageUrl = await _uploadImage(newImage);
      }

      final updatedFood = Food(
        id: food.id,
        name: food.name,
        description: food.description,
        price: food.price,
        imageUrl: imageUrl,
        stallName: food.stallName,
      );

      final batch = _firestore.batch();
      final foodRef = _firestore.collection('foods').doc(food.id);
      batch.update(foodRef, updatedFood.toFirestore());
      await batch.commit();
    } finally {
      _setSaving(false);
    }
  }

  Future<void> deleteFood(String foodId) async {
    _setSaving(true);

    try {
      final foodRef = _firestore.collection('foods').doc(foodId);
      await foodRef.delete();
    } finally {
      _setSaving(false);
    }
  }

  void _setSaving(bool isSaving) {
    _isSaving = isSaving;
    notifyListeners();
  }
}