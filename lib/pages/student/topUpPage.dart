import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TopUpPage extends StatefulWidget {
  final double currentBalance;

  const TopUpPage({super.key, required this.currentBalance});

  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  // Step 1: Create a PaymentIntent using Stripe API
  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      const String secretKey = 'sk_test_51QrF5kJgKP1zqUZZw2qjL4NVerclTg6KPDzAyPN4ESQozjvTHimJ1RzzQflSQrjVHphsiUgL5DVoGrwm8Tg93RZ200IDZSHlMb'; // Replace with your Stripe Secret Key
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (double.parse(amount) * 100).round().toString(), // Ensure this is an integer
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      print('Stripe Response Status: ${response.statusCode}');
      print('Stripe Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        print('Error creating PaymentIntent: ${errorBody['error']['message']}');
        throw Exception('Failed to create PaymentIntent: ${errorBody['error']['message']}');
      }
    } catch (e) {
      print('Error creating PaymentIntent: $e');
      return null;
    }
  }

  // Step 2: Perform the top-up and handle Stripe payment
  Future<void> _performTopUp() async {
    final topUpAmount = double.tryParse(_controller.text);
    if (topUpAmount == null || topUpAmount <= 0 || topUpAmount < 2.00) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount (Minimum amount is RM2.00)')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Step 3: Create PaymentIntent on Stripe server
      final paymentIntent = await createPaymentIntent(topUpAmount.toString(), 'myr');

      if (paymentIntent == null || paymentIntent['client_secret'] == null) {
        throw Exception('Failed to create payment intent');
      }

      // Step 4: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'APEat',
        ),
      );

      // Step 5: Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 6: If payment is successful, update Firestore
      final newBalance = widget.currentBalance + topUpAmount;
      final user = FirebaseAuth.instance.currentUser!;
      final email = user.email!;
      final id = email.split('@')[0].toLowerCase();

      await FirebaseFirestore.instance.collection('students').doc(id).update({
        'balance': newBalance,
      });

      // Show success message
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                Text('Transaction in progress...'),
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
