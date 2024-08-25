import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KitchenFeedbackPage extends StatefulWidget {
  final String stallName;

  const KitchenFeedbackPage({Key? key, required this.stallName}) : super(key: key);

  @override
  State<KitchenFeedbackPage> createState() => _KitchenFeedbackPageState();
}

class _KitchenFeedbackPageState extends State<KitchenFeedbackPage> {
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _calculateAverageRating(List<QueryDocumentSnapshot> docs) async {
    if (docs.isEmpty) {
      setState(() {
        averageRating = 0.0;
      });
      return;
    }

    final List<int> ratings = docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as int)
        .toList();

    //[1,5,2,3], (1,5)=>1+5=6, (6,2)=>6+2=8, (8,3)=>8+3=11
    final double avgRating = ratings.reduce((a, b) => a + b) / ratings.length; // Get average of all rating

    setState(() {
      averageRating = avgRating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text("Feedback"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('feedbacks')
                .where('stall_name', isEqualTo: widget.stallName)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No feedback available'));
              }

              // Calculate and fetch the rating
              _calculateAverageRating(snapshot.data!.docs);

              final feedbackData = snapshot.data!.docs.map((doc) {
                return doc.data() as Map<String, dynamic>;
              }).toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Feedback Received',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StarRating(rating: averageRating.round()), // Use averageRating here
                    const SizedBox(height: 20),
                    Column(
                      children: feedbackData.map((feedback) {
                        return FeedbackBox(
                          feedbackContent: feedback['feedback_content'],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FeedbackBox extends StatelessWidget {
  final String feedbackContent;

  const FeedbackBox({
    Key? key,
    required this.feedbackContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(122, 178, 178, 1),
              width: 2.0,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                feedbackContent,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StarRating extends StatelessWidget {
  final int rating;
  final int maxRating;
  final Color color;
  final double starSize;

  const StarRating({
    Key? key,
    this.rating = 0,
    this.maxRating = 5,
    this.color = Colors.amber,
    this.starSize = 35.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: color,
          size: starSize,
        );
      }),
    );
  }
}
