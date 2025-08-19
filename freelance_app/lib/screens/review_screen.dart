import 'package:flutter/material.dart';
import 'package:freelance_app/models/review_model.dart';
import 'package:freelance_app/services/review_service.dart';

class SubmitReviewScreen extends StatefulWidget {
  final int reviewerId;
  final int revieweeId;
  final int jobId;

  const SubmitReviewScreen({
    required this.reviewerId,
    required this.revieweeId,
    required this.jobId,
  });

  @override
  _SubmitReviewScreenState createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final _feedbackController = TextEditingController();
  int _rating = 5;

  void _submitReview() async {
    Review review = Review(
      reviewerId: widget.reviewerId,
      revieweeId: widget.revieweeId,
      jobId: widget.jobId,
      rating: _rating,
      feedback: _feedbackController.text,
    );

    bool success = await ReviewService().submitReview(review);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review submitted!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit review")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit Review")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Rate from 1 to 5"),
            DropdownButton<int>(
              value: _rating,
              onChanged: (value) => setState(() => _rating = value!),
              items: List.generate(5, (index) => index + 1)
                  .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                  .toList(),
            ),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(labelText: "Your feedback"),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _submitReview, child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
