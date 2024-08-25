import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/student/order.dart';
import '../../view_model/student/student_order_view_model.dart';
import 'feedback.dart';

class StudentOrderPage extends StatefulWidget {
  const StudentOrderPage({super.key});

  @override
  _StudentOrderPageState createState() => _StudentOrderPageState();
}

class _StudentOrderPageState extends State<StudentOrderPage> {
  late Future<List<StudentOrder>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = Provider.of<StudentOrderViewModel>(context, listen: false).fetchOrders();
  }

  void _refreshOrders() {
    setState(() {
      _futureOrders = Provider.of<StudentOrderViewModel>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Order"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<StudentOrder>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("An error occurred."));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders placed."));
          } else {
            var orders = snapshot.data!;
            var completedOrders = orders.where((order) => order.orderStatus).toList();
            var preparingOrders = orders.where((order) => !order.orderStatus).toList();

            return Column(
              children: [
                Container(
                  color: const Color.fromRGBO(205, 232, 229, 1),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "Ready to Pick Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "(Click the order to give feedback)",
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: completedOrders.length,
                    itemBuilder: (context, index) {
                      var order = completedOrders[index];
                      return GestureDetector(
                        onTap: () {
                          if (!order.feedbackStatus) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FeedbackPage(
                                  documentId: order.id,
                                  stallName: order.stallName,
                                  onFeedbackSubmitted: _refreshOrders,
                                ),
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Feedback Submitted"),
                                content: const Text(
                                    "Feedback submitted. Thank you for the feedback!"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: ListTile(
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                  color: Color.fromRGBO(122, 178, 178, 1),
                                  width: 2.0,
                                ),
                              ),
                              leading: const Icon(Icons.fastfood),
                              title: Text(order.foodTitle),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Description: ${order.foodDescription}'),
                                  Text('Price: RM ${order.foodPrice.toStringAsFixed(2)}'),
                                  Text('Quantity: ${order.quantity}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    order.date,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    order.time,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  color: const Color.fromRGBO(205, 232, 229, 1),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "Preparing Orders",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: preparingOrders.length,
                    itemBuilder: (context, index) {
                      var order = preparingOrders[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(
                                color: Colors.red,
                                width: 2.0,
                              ),
                            ),
                            leading: const Icon(Icons.fastfood),
                            title: Text(order.foodTitle),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description: ${order.foodDescription}'),
                                Text('Price: RM ${order.foodPrice.toStringAsFixed(2)}'),
                                Text('Quantity: ${order.quantity}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  order.date,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  order.time,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
