import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:APEat/pages/kitchenStaff/kitchenNotificationPage.dart';

class KitchenHomePage extends StatefulWidget {
  final String stallName;

  const KitchenHomePage({Key? key, required this.stallName}) : super(key: key);

  @override
  State<KitchenHomePage> createState() => _KitchenHomePageState();
}

class _KitchenHomePageState extends State<KitchenHomePage> {
  String searchKeyword = '';
  late FocusNode _searchFocusNode;
  bool _hasNewOrders = false; // red dot notification order

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();

    // Listen for new orders
    FirebaseFirestore.instance
        .collection('orders')
        .where('stall_name', isEqualTo: widget.stallName)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docChanges
          .any((change) => change.type == DocumentChangeType.added)) {
        setState(() {
          _hasNewOrders = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _updateSearch(String value) {
    setState(() {
      searchKeyword = value.toLowerCase();
    });
  }

  void _unfocusSearchBar() {
    _searchFocusNode.unfocus();
  }

  void _clearNewOrdersFlag() {
    setState(() {
      _hasNewOrders = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusSearchBar, // Unfocus search bar when tapped outside
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
        appBar: AppBar(
          title: const Text("Homepage"),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
          foregroundColor: Colors.white,
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    _clearNewOrdersFlag();
                    // Navigate to Notification
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KitchenNotificationPage(
                            stallName: widget.stallName),
                      ),
                    );
                  },
                ),
                if (_hasNewOrders)
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              const Align(
                alignment: AlignmentDirectional(0, 0),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Order Receive',
                    style: TextStyle(
                      fontFamily: 'Readex Pro',
                      fontSize: 16,
                      letterSpacing: 0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search TP Number',
                    contentPadding: const EdgeInsets.all(10.0),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onChanged: _updateSearch,
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('stall_name', isEqualTo: widget.stallName)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No orders available'));
                    }

                    final orders = snapshot.data!.docs.where((order) {
                      return !order['order_status'] &&
                          (searchKeyword.isEmpty ||
                              order['tp_number']
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchKeyword));
                    }).toList();

                    if (orders.isEmpty) {
                      return const Center(
                        child: Text('No matching orders found'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildOrderReceiveCard(
                            context,
                            foodTitle: order['food_title'] ?? 'N/A',
                            value: order['quantity']?.toString() ?? 'N/A',
                            tpNumber: order['tp_number'] ?? 'N/A',
                            orderId: order.id, // Pass the order document ID
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
      ),
    );
  }

  Widget _buildOrderReceiveCard(
    BuildContext context, {
    required String foodTitle,
    required String value,
    required String tpNumber,
    required String orderId, // Add orderId parameter
  }) {
    return Container(
      width: 352,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(238, 247, 255, 1),
        borderRadius: BorderRadius.circular(16),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: const Color.fromRGBO(77, 134, 156, 1),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Column for food title and value
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodTitle,
                    style: const TextStyle(
                      fontFamily: 'Readex Pro',
                      fontSize: 16,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Readex Pro',
                      fontSize: 16,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Column for TP number
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                tpNumber,
                style: const TextStyle(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          // Column for Ready button
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(context, orderId,
                      tpNumber); // Pass orderId to confirmation dialog
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                ),
                child: const Text(
                  'Ready',
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Colors.black,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
      BuildContext context, String orderId, String tpNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(
              'Notify the student with TP Number $tpNumber that the order is ready?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update order status to true in Firestore
                FirebaseFirestore.instance
                    .collection('orders')
                    .doc(orderId)
                    .update({
                  'order_status': true,
                }).then((value) {
                  // Show notification
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Student with TP Number $tpNumber has been notified.')),
                  );
                }).catchError((error) {
                  print("Failed to update order status: $error");
                  // Handle error
                });
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
