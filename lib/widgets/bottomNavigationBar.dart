import 'package:flutter/material.dart';

BottomNavigationBarItem buildNavItem(
    {required IconData icon, required String label, required int index, required int currentIndex}) {
  bool isActive = currentIndex == index;
  Color iconColor = isActive ? const Color.fromRGBO(77, 134, 156, 1) : Colors.black;

  return BottomNavigationBarItem(
    icon: Container(
      decoration: BoxDecoration(
        border: Border.all(color: iconColor, width: 1.5),
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(
        icon,
        color: iconColor,
      ),
    ),
    label: label,
  );
}