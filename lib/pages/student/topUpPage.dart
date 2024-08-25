import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TopUpPage extends StatefulWidget {
  final double currentBalance;

  const TopUpPage({super.key, required this.currentBalance});

  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  Future<void> _performTopUp() async {
    final topUpAmount = double.tryParse(_controller.text);
    if (topUpAmount == null || topUpAmount <= 0 || topUpAmount < 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulate transaction delay

    // Update the balance in Firestore
    final newBalance = widget.currentBalance + topUpAmount;
    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email!;
    final id = email.split('@')[0].toLowerCase();

    await FirebaseFirestore.instance.collection('students').doc(id).update({
      'balance': newBalance,
    });

    setState(() {
      isLoading = false;
    });

    // Show confirmation message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Successful'),
        content: Text('Your new balance is RM${newBalance.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to the previous page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Top Up"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Enter Top-Up Amount',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount (RM)',
              ),
            ),
            const SizedBox(height: 30),
            isLoading
                ? const Column(
              children: [
                SizedBox(height: 30),
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Transaction in progress...')
              ],
            )
                : ElevatedButton(
              onPressed: _performTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Top-Up'),
            ),
          ],
        ),
      ),
    );
  }
}
