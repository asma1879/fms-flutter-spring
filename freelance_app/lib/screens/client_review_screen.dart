import 'package:flutter/material.dart';
import 'package:freelance_app/models/reviewDTO.dart';
import 'package:freelance_app/services/review_service.dart';

class ClientReviewsScreen extends StatefulWidget {
  final int clientId;

  const ClientReviewsScreen({Key? key, required this.clientId}) : super(key: key);

  @override
  State<ClientReviewsScreen> createState() => _ClientReviewsScreenState();
}

class _ClientReviewsScreenState extends State<ClientReviewsScreen> {
  late Future<List<ReviewDTO>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewService().getDetailedReviewsForClient(widget.clientId);
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  String _formatDate(String dateTimeStr) {
    // Just show yyyy-MM-dd, you can customize this more if needed
    if (dateTimeStr.isEmpty) return "";
    return dateTimeStr.split('T').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews from Freelancers"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<ReviewDTO>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Failed to load reviews: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No reviews yet."));
          } else {
            final reviews = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job Title
                        Text(
                          review.jobTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Reviewer Name (Freelancer)
                        Text(
                          "By: ${review.reviewerName}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Rating Stars
                        _buildStarRating(review.rating),

                        const SizedBox(height: 12),

                        // Feedback Text
                        Text(
                          review.feedback.isNotEmpty
                              ? review.feedback
                              : "No feedback provided.",
                          style: const TextStyle(fontSize: 16, height: 1.3),
                        ),

                        const SizedBox(height: 12),

                        // Review Date
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            _formatDate(review.reviewTime.toString()),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
