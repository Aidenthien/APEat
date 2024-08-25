import 'package:APEat/pages/student/studentHomepage.dart';
import 'package:APEat/pages/student/studentOrder.dart';
import 'package:APEat/pages/student/studentProfile.dart';
import 'package:APEat/pages/student/studentStall.dart';
import 'package:flutter/material.dart';
import 'package:APEat/widgets/bottomNavigationBar.dart';

class StudentMainPage extends StatefulWidget {
  final int initialIndex;
  const StudentMainPage({super.key, this.initialIndex = 0});

  @override
  State<StudentMainPage> createState() => _StudentMainPageState();
}

class _StudentMainPageState extends State<StudentMainPage> {
  late int currentIndex;
  List<Widget> pages = []; // Initialize an empty list for pages

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex; // Use the initial index passed to the widget
    pages = [
      StudentHomepage(onOrderNow: () => onTap(1)), // Pass the callback function
      const StudentStorePage(),
      StudentOrderPage(),
      const StudentProfilePage(),
    ];
  }

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(238, 247, 255, 1),
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: const Color.fromRGBO(77, 134, 156, 1),
        // Active label and icon color
        unselectedItemColor: Colors.black,
        // Inactive label and icon color
        items: [
          buildNavItem(icon: Icons.home,  label: 'Home', index: 0, currentIndex: currentIndex),
          buildNavItem(icon: Icons.restaurant,  label: 'Store', index: 1, currentIndex: currentIndex),
          buildNavItem(icon: Icons.receipt_long_rounded,  label: 'Order', index: 2, currentIndex: currentIndex),
          buildNavItem(icon: Icons.person_outline_rounded,  label: 'Profile', index: 3, currentIndex: currentIndex),
        ],
      ),
    );
  }
}
