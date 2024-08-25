class StudentOrder {
  final String id;
  final String date;
  final String time;
  final bool orderStatus;
  final bool feedbackStatus;
  final int quantity;
  final String tpNumber;
  final String stallName;
  final String foodDescription;
  final double foodPrice;
  final String foodTitle;

  StudentOrder({
    required this.id,
    required this.date,
    required this.time,
    required this.orderStatus,
    required this.feedbackStatus,
    required this.quantity,
    required this.tpNumber,
    required this.stallName,
    required this.foodDescription,
    required this.foodPrice,
    required this.foodTitle,
  });

  factory StudentOrder.fromFirestore(Map<String, dynamic> data, String id) {
    return StudentOrder(
      id: id,
      date: data['date'],
      time: data['time'],
      orderStatus: data['order_status'],
      feedbackStatus: data['feedback_status'],
      quantity: data['quantity'],
      tpNumber: data['tp_number'],
      stallName: data['stall_name'],
      foodDescription: data['food_description'],
      foodPrice: data['food_price'],
      foodTitle: data['food_title'],
    );
  }
}
