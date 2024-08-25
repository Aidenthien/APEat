import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class KitchenNotificationPage extends StatefulWidget {
  final String stallName;

  const KitchenNotificationPage({Key? key, required this.stallName}) : super(key: key);

  @override
  _KitchenNotificationPageState createState() => _KitchenNotificationPageState();
}

class _KitchenNotificationPageState extends State<KitchenNotificationPage> {
  String searchKeyword = '';
  late FocusNode _searchFocusNode;
  late String currentMonth;
  late String currentYear;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    final now = DateTime.now();
    currentMonth = DateFormat('MM').format(now);
    currentYear = DateFormat('yyyy').format(now);
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _updateDisplayedNotifications(String value) {
    setState(() {
      searchKeyword = value;
    });
  }

  void _unfocusSearchBar() {
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Notification"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        top: true,
        child: GestureDetector(
          onTap: _unfocusSearchBar,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                  onChanged: _updateDisplayedNotifications,
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
                      return const Center(child: Text('No notifications available'));
                    }

                    final notifications = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .where((notification) {
                      final date = notification['date']?.toString() ?? '';
                      final parts = date.split('/');
                      if (parts.length != 3) return false;
                      final month = parts[1];
                      final year = parts[2];
                      return month == currentMonth && year == currentYear;
                    })
                        .where((notification) =>
                        notification['tp_number']
                            .toString()
                            .toLowerCase()
                            .contains(searchKeyword.toLowerCase()))
                        .toList();

                    if (notifications.isEmpty) {
                      return const Center(child: Text('No matching notifications'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildOrderReceiveCard(
                            context,
                            foodTitle: notification['food_title'] ?? 'N/A',
                            value: notification['quantity']?.toString() ?? 'N/A',
                            tpNumber: notification['tp_number'] ?? 'N/A',
                            orderTime: notification['time'] ?? 'N/A',
                            orderDate: notification['date'] ?? 'N/A',
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
        required String orderTime,
        required String orderDate,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(238, 247, 255, 1),
        border: Border.all(
          color: const Color.fromRGBO(122, 178, 178, 1),
          width: 3.0,
        ),
      ),
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tpNumber,
                      style: const TextStyle(
                        fontFamily: 'Readex Pro',
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      foodTitle,
                      style: const TextStyle(
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Order At',
                      style: TextStyle(
                        fontFamily: 'Readex Pro',
                        color: Color(0xFF7F7F7F),
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      orderTime,
                      style: const TextStyle(
                        fontFamily: 'Readex Pro',
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      orderDate,
                      style: const TextStyle(
                        fontFamily: 'Readex Pro',
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
