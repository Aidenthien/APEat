import 'package:APEat/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KitchenProfilePage extends StatefulWidget {
  final String stallName;

  const KitchenProfilePage({Key? key, required this.stallName}) : super(key: key);

  @override
  State<KitchenProfilePage> createState() => _KitchenProfilePageState();
}

class _KitchenProfilePageState extends State<KitchenProfilePage> {
  User? user;
  String? displayName;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      displayName = user!.email?.split('@')[0];
      fetchProfileImageUrl(user!.email!);
    }
  }

  Future<void> fetchProfileImageUrl(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('profile')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          profileImageUrl = snapshot.docs.first.data()['profile_url'];
        });
      }
    } catch (e) {
      print('Error fetching profile image URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Staff Details"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm Sign Out"),
                    content: const Text("Are you sure you want to sign out?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close the dialog
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                        },
                        child: const Text("Sign Out"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Color.fromRGBO(205, 232, 229, 1),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : const AssetImage('assets/images/profile_pic.png') as ImageProvider,
                ),
                const SizedBox(height: 70),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
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
                  child: Text(
                    user?.email ?? 'Staff Email',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
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
                  child: Text(
                    displayName ?? 'Staff Name',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
