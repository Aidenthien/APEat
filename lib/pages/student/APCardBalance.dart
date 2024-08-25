import 'package:APEat/pages/student/topUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TopUpMethod extends StatefulWidget {
  const TopUpMethod({super.key});

  @override
  State<TopUpMethod> createState() => _TopUpMethodState();
}

class _TopUpMethodState extends State<TopUpMethod> {
  late User user;
  double balance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    final email = user.email!;
    final id = email.split('@')[0].toLowerCase();

    try {
      final doc =
          await FirebaseFirestore.instance.collection('students').doc(id).get();
      if (doc.exists) {
        setState(() {
          balance = doc.data()!['balance'].toDouble();
          isLoading = false;
        });
      } else {
        print('Document does not exist for ID: $id');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching balance: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToTopUpPage() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => TopUpPage(currentBalance: balance),
      ),
    )
        .then((_) {
      _fetchBalance(); // Refresh balance after returning from top-up page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("APCard Balance"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 200,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
                border: const Border(
                  bottom: BorderSide(
                    color: Color.fromRGBO(122, 178, 178, 1),
                    width: 2.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            'RM${balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          const Center(
            child: Text(
              'Choose A Top Up Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _navigateToTopUpPage,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
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
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: const Text(
                  'E-wallet',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _navigateToTopUpPage,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
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
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: const Text(
                  'Online Banking',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _navigateToTopUpPage,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
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
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: const Text(
                  'Credit/Debit Card',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
