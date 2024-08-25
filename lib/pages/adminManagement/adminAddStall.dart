import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/adminManagement/stall_view_model.dart';

class adminAddStall extends StatefulWidget {
  const adminAddStall({super.key});

  @override
  State<adminAddStall> createState() {
    return _adminAddStallState();
  }
}

class _adminAddStallState extends State<adminAddStall> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StallViewModel>(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Add New Stall"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: viewModel.pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: viewModel.selectedImage != null
                          ? FileImage(viewModel.selectedImage!)
                          : null,
                      child: viewModel.selectedImage == null
                          ? const Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 30),
                  // Divider
                  const Divider(
                    thickness: 2,
                    color: Colors.black26,
                  ),
                  const SizedBox(height: 50),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromRGBO(77, 134, 156, 1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Stall Name',
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a stall name.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        viewModel.stallName = value!;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromRGBO(77, 134, 156, 1)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        viewModel.description = value!;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (viewModel.isSaving) const CircularProgressIndicator(),
                  if (!viewModel.isSaving)
                    ElevatedButton(
                      onPressed: () => viewModel.addStall(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add Stall'),
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
