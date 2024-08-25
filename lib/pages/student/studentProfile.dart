import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../login.dart';
import 'APCardBalance.dart';
import '../../model/student/student.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  late User user;
  Student? student;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    final email = user.email!;
    final id = email.split('@')[0]
        .toLowerCase(); // Ensure the ID matches the case in Firestore
    print('Fetching data for ID: $id');

    try {
      final doc = await FirebaseFirestore.instance.collection('students').doc(
          id).get();
      if (doc.exists) {
        print('Document found: ${doc.data()}');
        setState(() {
          student = Student.fromFirestore(doc.data()!);
        });
      } else {
        print('Document does not exist for ID: $id');
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Profile"),
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
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                          );
                        },
                        child: const Text("Sign Out"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout_rounded),
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
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 100,
                  backgroundImage: student != null
                      ? NetworkImage(student!.profileUrl)
                      : const AssetImage('assets/images/profile_pic.png'),
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
                    student != null ? student!.id : 'Loading...',
                    style: const TextStyle(fontSize: 16.0),
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
                    student != null ? student!.name : 'Loading...',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TopUpMethod()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Check Balance'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}