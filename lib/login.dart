import 'package:APEat/pages/adminManagement/adminMain.dart';
import 'package:APEat/pages/kitchenStaff/kitchenMain.dart';
import 'package:APEat/pages/student/studentMain.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

final _firebase = FirebaseAuth.instance;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _form = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isAuthenticating = false;
  var _stallName = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);

      // Fetch stall_name from Firestore based on enteredEmail
      final userSnapshot = await FirebaseFirestore.instance
          .collection('stalls')
          .where('stall_email', isEqualTo: _enteredEmail)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        _stallName = userSnapshot.docs.first['stall_name'];
        print('Stall Name in login: $_stallName'); // Print statement to check stall name
      }

      // Check the email domain to determine user role
      if (_enteredEmail.contains('@admin.apu')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainPage()),
        );
      } else if (_enteredEmail.contains('@kitchen.apu')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KitchenMainPage(stallName: _stallName)),
        );
      } else if (_enteredEmail.contains('@mail.apu')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentMainPage()),
        );
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _email() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'admin@apu.my',
      query: 'subject=Request to reset account password&body=I need help with resetting my password.',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(89, 150, 173, 1),
              Color.fromRGBO(205, 232, 229, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/images/APEat.png',
                          width: 280,
                          height: 280,
                        ),
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 280,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 280,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password cannot be empty';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (_isAuthenticating)
                        const CircularProgressIndicator(),
                      if (!_isAuthenticating)
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Login'),
                        ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Forgot your password? '),
                          GestureDetector(
                            onTap: _email,
                            child: const Text(
                              'Contact Admin',
                              style: TextStyle(
                                color: Color.fromRGBO(77, 134, 156, 1),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
