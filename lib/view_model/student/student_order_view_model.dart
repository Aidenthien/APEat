import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/student/order.dart';

class StudentOrderViewModel extends ChangeNotifier {
  Future<List<StudentOrder>> fetchOrders() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    String userEmail = user.email!;
    String tpNumber = userEmail.split('@').first;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('tp_number', isEqualTo: tpNumber)
        .get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return StudentOrder.fromFirestore(data, doc.id);
    }).toList();
  }
}
