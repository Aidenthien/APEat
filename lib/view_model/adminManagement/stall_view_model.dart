import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StallViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  var stallName = '';
  var description = '';
  File? selectedImage;
  var isSaving = false;
  String? imageUrl;

  void pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      selectedImage = File(pickedImage.path);
      notifyListeners();
    }
  }

  void initializeStall(DocumentSnapshot stall) {
    stallName = stall['stall_name'];
    description = stall['stall_description'];
    imageUrl = stall['stall_image_url'];
    selectedImage = null;
    notifyListeners();
  }

  Future<void> createUser(String email, String password) async {
    try {
      final FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );
      final FirebaseAuth secondaryAuth =
          FirebaseAuth.instanceFor(app: secondaryApp);

      await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await secondaryApp.delete();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addStall(BuildContext context) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid || selectedImage == null) {
      return;
    }
    formKey.currentState!.save();

    try {
      isSaving = true;
      notifyListeners();

      final email =
          '${stallName.replaceAll(' ', '').toLowerCase()}@kitchen.apu';
      final password = stallName.replaceAll(' ', '').toLowerCase();
      await createUser(email, password);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('stall_images')
          .child('${DateTime.now().toIso8601String()}.jpg');

      await storageRef.putFile(selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('stalls').add({
        'stall_name': stallName,
        'stall_description': description,
        'stall_image_url': imageUrl,
        'stall_email': email,
      });

      isSaving = false;
      notifyListeners();

      _showSuccessDialog(
          context, 'Success', 'The stall has been added successfully!');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save stall: $error'),
        ),
      );
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> editStall(BuildContext context, DocumentSnapshot stall) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    formKey.currentState!.save();

    try {
      isSaving = true;
      notifyListeners();

      String? imageUrl = this.imageUrl;
      if (selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('stall_images')
            .child('${DateTime.now().toIso8601String()}.jpg');

        await storageRef.putFile(selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final batch = FirebaseFirestore.instance.batch();

      final stallRef = stall.reference;
      batch.update(stallRef, {
        'stall_name': stallName,
        'stall_description': description,
        'stall_image_url': imageUrl,
      });

      await batch.commit();

      isSaving = false;
      notifyListeners();

      _showSuccessDialog(context, 'Edit Successful', 'Changes are saved!');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save stall: $error'),
        ),
      );

      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteStall(BuildContext context, DocumentSnapshot stall) async {
    try {
      isSaving = true;
      notifyListeners();

      await stall.reference.delete();

      isSaving = false;
      notifyListeners();

      _showSuccessDialog(context, 'Delete Success', 'Stall has been deleted!');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete stall: $error'),
        ),
      );

      isSaving = false;
      notifyListeners();
    }
  }

  void _showSuccessDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void confirmDelete(BuildContext context, DocumentSnapshot stall) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: const Text('Do you want to delete this stall?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              deleteStall(context, stall);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
