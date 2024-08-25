import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  final String documentId;
  final String stallName;
  final VoidCallback onFeedbackSubmitted;

  const FeedbackPage({
    super.key,
    required this.documentId,
    required this.stallName,
    required this.onFeedbackSubmitted,
  });

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 0;

  void _submitFeedback() async {
    if (_rating == 0 || _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and feedback')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('feedbacks').add({
      'stall_name': widget.stallName,
      'rating': _rating,
      'feedback_content': _feedbackController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update feedback_status in the order document
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.documentId)
        .update({'feedback_status': true});

    widget.onFeedbackSubmitted();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thank You!"),
        content: const Text("Thank you for the feedback!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(205, 232, 229, 1),
      appBar: AppBar(
        title: const Text('Feedback'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rate your experience:', style: TextStyle(fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text('Feedback:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your feedback here',
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(77, 134, 156, 1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
