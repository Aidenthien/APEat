import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:APEat/pages/kitchenStaff/kitchenFeedbackPage.dart';
import 'package:APEat/pages/kitchenStaff/kitchenHomepage.dart';
import 'package:APEat/pages/kitchenStaff/kitchenMenu.dart';
import 'package:APEat/pages/kitchenStaff/kitchenProfilePage.dart';
import 'package:APEat/widgets/bottomNavigationBar.dart';

class KitchenMainPage extends StatefulWidget {
  final String stallName;

  const KitchenMainPage({Key? key, required this.stallName}) : super(key: key);

  @override
  State<KitchenMainPage> createState() => _KitchenMainPageState();
}

class _KitchenMainPageState extends State<KitchenMainPage> {
  int currentIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    print('Stall Name in main: ${widget.stallName}');
    pages = [
      KitchenHomePage(stallName: widget.stallName),
      KitchenMenu(stallName: widget.stallName),
      KitchenFeedbackPage(stallName: widget.stallName),
      KitchenProfilePage(stallName: widget.stallName),
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
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: const Color.fromRGBO(77, 134, 156, 1),
        unselectedItemColor: Colors.black,
        items: [
          buildNavItem(icon: Icons.home, label: 'Home', index: 0, currentIndex: currentIndex),
          buildNavItem(icon: Icons.restaurant_menu, label: 'Menu', index: 1, currentIndex: currentIndex),
          buildNavItem(icon: Icons.thumb_up_outlined, label: 'Feedback', index: 2, currentIndex: currentIndex),
          buildNavItem(icon: Icons.person_outline_rounded, label: 'Profile', index: 3, currentIndex: currentIndex),
        ],
      ),
    );
  }
}
