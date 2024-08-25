import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class adminReport extends StatelessWidget {
  final String foodStallName;

  adminReport({required this.foodStallName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: Text('Report for $foodStallName'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color.fromRGBO(77, 134, 156, 1), width: 20),
              ),
              child: Center(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('stall_name', isEqualTo: foodStallName)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(color: Colors.white);
                    }

                    if (snapshot.hasError) {
                      return const Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }

                    double totalSales = 0;
                    for (var doc in snapshot.data!.docs) {
                      var salesValue = doc['food_price'];
                      if (salesValue is String) {
                        salesValue = double.tryParse(salesValue) ?? 0.0;
                      } else if (salesValue is int) {
                        salesValue = salesValue.toDouble();
                      }
                      totalSales += salesValue;
                    }

                    return Text(
                      'RM ${totalSales.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Divider
            const Divider(
              thickness: 2,
              color: Colors.black26,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('stall_name', isEqualTo: foodStallName)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Error fetching sales data"));
                  }

                  final salesData = snapshot.data?.docs ?? [];

                  if (salesData.isEmpty) {
                    return const Center(child: Text("No sales data available"));
                  }

                  return ListView.builder(
                    itemCount: salesData.length,
                    itemBuilder: (context, index) {
                      final sales = salesData[index];
                      final date = sales['date'];
                      var amount = sales['food_price'];
                      if (amount is String) {
                        amount = double.tryParse(amount) ?? 0.0;
                      }

                      return Card(
                        key: ValueKey(sales.id),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            'Date: $date',
                            style: const TextStyle(fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Sales Amount: RM $amount',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
