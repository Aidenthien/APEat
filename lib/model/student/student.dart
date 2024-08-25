class Student {
  final String id;
  final String name;
  final String profileUrl;
  final double balance;

  Student({required this.id, required this.name, required this.balance, required this.profileUrl});

  factory Student.fromFirestore(Map<String, dynamic> data) {
    return Student(
      id: data['id'] as String,
      name: data['name'] as String,
      profileUrl: data['profile_url'] as String,
      balance: data['balance'] as double,
    );
  }
}