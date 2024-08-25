import 'package:APEat/pages/adminManagement/adminHomepage.dart';
import 'package:APEat/pages/adminManagement/adminManageStall.dart';
import 'package:flutter/material.dart';
import '../../widgets/bottomNavigationBar.dart';
import 'adminProfile.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int currentIndex = 0;
  List pages = [
    AdminHomepage(),
    adminManageStall(),
    adminProfile(),
  ];

  void onTap(int index){
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromRGBO(77, 134, 156, 1), // Active label and icon color
        unselectedItemColor: Colors.black, // Inactive label and icon color
        items: [
          buildNavItem(icon: Icons.show_chart, label: 'Stats', index: 0, currentIndex: currentIndex),
          buildNavItem(icon: Icons.storefront, label: 'Food Stall', index: 1, currentIndex: currentIndex),
          buildNavItem(icon: Icons.person_outline_rounded, label: 'Profile', index: 2, currentIndex: currentIndex),
        ],
      ),
    );
  }
}
