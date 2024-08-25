import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:APEat/view_model/kitchenStaff/food_view_model.dart';

class KitchenAddFood extends StatelessWidget {
  final String stallName;

  const KitchenAddFood({Key? key, required this.stallName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => KitchenFoodViewModel(),
      child: KitchenAddFoodForm(stallName: stallName),
    );
  }
}

class KitchenAddFoodForm extends StatefulWidget {
  final String stallName;

  const KitchenAddFoodForm({Key? key, required this.stallName}) : super(key: key);

  @override
  State<KitchenAddFoodForm> createState() => _KitchenAddFoodFormState();
}

class _KitchenAddFoodFormState extends State<KitchenAddFoodForm> {
  final _form = GlobalKey<FormState>();
  var _foodName = '';
  var _description = '';
  var _foodPrice = 0.0;
  File? _selectedImage;

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _submit() {
    if (!_form.currentState!.validate() || _selectedImage == null) {
      return;
    }
    _form.currentState!.save();

    Provider.of<KitchenFoodViewModel>(context, listen: false).addFood(
      name: _foodName,
      description: _description,
      price: _foodPrice,
      stallName: widget.stallName,
      image: _selectedImage!,
    ).then((_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: const Text('The food has been added successfully!'),
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
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save food: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = Provider.of<KitchenFoodViewModel>(context).isSaving;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text('Add New Food'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Center(
                    child: Text(
                      "Click image icon to add image",
                      style: TextStyle(
                        height: 4,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(thickness: 2, color: Colors.black26),
                  const SizedBox(height: 30),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Food Name',
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a food name.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _foodName = value!;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _description = value!;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      border: OutlineInputBorder(),
                    ),
                    // only number value can be accept (regex)
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // 2 decimal places
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a price.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _foodPrice = double.parse(value!);
                    },
                  ),
                  const SizedBox(height: 30),
                  isSaving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Add Food'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
