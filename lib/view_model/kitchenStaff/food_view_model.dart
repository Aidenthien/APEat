import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import '../../model/kitchenStaff/food.dart';

class KitchenFoodViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  final String cloudName = "dgxbp7dy3";  // Replace with your Cloudinary cloud name
  final String apiKey = "EcoEatSmart";  // Replace with your Cloudinary API key
  final String apiSecret = "jj6IKoqHxuLDFNwo-NqVfLsBDUw";  // Replace with your Cloudinary API secret

  Future<String> _uploadImage(File image) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'ecoeatsmart'  // Replace with your preset name
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    var response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final responseData = json.decode(responseBody);
      return responseData['secure_url'];  // Return Cloudinary image URL
    } else {
      throw Exception("Cloudinary Upload Failed: ${response.reasonPhrase} - $responseBody");
    }
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