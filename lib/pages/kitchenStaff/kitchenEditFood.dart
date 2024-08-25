import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:APEat/model/kitchenStaff/food.dart';
import 'package:APEat/view_model/kitchenStaff/food_view_model.dart';

class KitchenEditFood extends StatelessWidget {
  final Food food;

  const KitchenEditFood({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => KitchenFoodViewModel(),
      child: KitchenEditFoodForm(food: food),
    );
  }
}

class KitchenEditFoodForm extends StatefulWidget {
  final Food food;

  const KitchenEditFoodForm({Key? key, required this.food}) : super(key: key);

  @override
  State<KitchenEditFoodForm> createState() => _KitchenEditFoodFormState();
}

class _KitchenEditFoodFormState extends State<KitchenEditFoodForm> {
  final _form = GlobalKey<FormState>();
  late String _foodName;
  late String _description;
  late double _foodPrice;
  File? _newImage;

  @override
  void initState() {
    super.initState();
    _foodName = widget.food.name;
    _description = widget.food.description;
    _foodPrice = widget.food.price;
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _newImage = File(pickedImage.path);
      });
    }
  }

  void _submit() {
    if (!_form.currentState!.validate() || (_newImage == null && widget.food.imageUrl.isEmpty)) {
      return;
    }
    _form.currentState!.save();

    final updatedFood = Food(
      id: widget.food.id,
      name: _foodName,
      description: _description,
      price: _foodPrice,
      imageUrl: _newImage != null ? _newImage!.path : widget.food.imageUrl,
      stallName: widget.food.stallName,
    );

    Provider.of<KitchenFoodViewModel>(context, listen: false).updateFood(updatedFood, _newImage).then((_) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: const Text('The food has been updated successfully!'),
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
        SnackBar(content: Text('Failed to update food: $error')),
      );
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to delete this food?'),
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
              Provider.of<KitchenFoodViewModel>(context, listen: false)
                  .deleteFood(widget.food.id)
                  .then((_) {
                Navigator.of(context).pop();
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete food: $error')),
                );
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = Provider.of<KitchenFoodViewModel>(context).isSaving;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text('Edit Food'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
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
                      backgroundImage: _newImage != null
                          ? FileImage(_newImage!)
                          : (widget.food.imageUrl.isNotEmpty ? NetworkImage(widget.food.imageUrl) : null),
                      child: _newImage == null && widget.food.imageUrl.isEmpty
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
                    initialValue: _foodName,
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
                    initialValue: _description,
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
                    initialValue: _foodPrice.toStringAsFixed(2),
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
                    child: const Text('Save Changes'),
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
