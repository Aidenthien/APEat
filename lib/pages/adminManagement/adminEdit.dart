import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../view_model/adminManagement/stall_view_model.dart';

class adminEdit extends StatefulWidget {
  final DocumentSnapshot stall;

  const adminEdit({super.key, required this.stall});

  @override
  State<adminEdit> createState() {
    return _adminEditState();
  }
}

class _adminEditState extends State<adminEdit> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<StallViewModel>(context, listen: false);
    viewModel.initializeStall(widget.stall);
    viewModel.stallName = widget.stall['stall_name'];
    viewModel.description = widget.stall['stall_description'];
    viewModel.imageUrl = widget.stall['stall_image_url'];
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StallViewModel>(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Edit Stall"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => viewModel.confirmDelete(context, widget.stall),
          ),
        ],
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
                          : viewModel.imageUrl != null
                          ? NetworkImage(viewModel.imageUrl!) as ImageProvider
                          : null,
                      child: viewModel.selectedImage == null && viewModel.imageUrl == null
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
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      initialValue: viewModel.stallName,
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
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      initialValue: viewModel.description,
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
                      onPressed: () => viewModel.editStall(context, widget.stall),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
                        foregroundColor: Colors.white,
                      ),
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
