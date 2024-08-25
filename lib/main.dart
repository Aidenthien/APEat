import 'package:APEat/view_model/adminManagement/stall_view_model.dart';
import 'package:APEat/view_model/student/student_order_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:provider/provider.dart';
import 'package:APEat/view_model/student/cartProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => StudentOrderViewModel()),
        ChangeNotifierProvider(create: (context) => StallViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'APEat',
      home: Login(),
    );
  }
}
