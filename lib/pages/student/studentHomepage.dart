import 'package:flutter/material.dart';

class StudentHomepage extends StatefulWidget {
  final VoidCallback onOrderNow;

  const StudentHomepage({super.key, required this.onOrderNow});

  @override
  State<StudentHomepage> createState() => _StudentHomepageState();
}

class _StudentHomepageState extends State<StudentHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Homepage"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              'Welcome',
              style: TextStyle(
                fontSize: 60,
                color: Color.fromRGBO(77, 134, 156, 1),
              ),
            ),
          ),
          const Center(
            child: Text(
              'to',
              style: TextStyle(
                fontSize: 60,
                color: Color.fromRGBO(77, 134, 156, 1),
              ),
            ),
          ),
          const Center(
            child: Text(
              'APEat',
              style: TextStyle(
                fontSize: 60,
                color: Color.fromRGBO(77, 134, 156, 1),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: widget.onOrderNow, // Use the passed callback function
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Order Now'),
          ),
        ],
      ),
    );
  }
}
