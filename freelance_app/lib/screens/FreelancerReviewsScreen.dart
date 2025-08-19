import 'package:flutter/material.dart';
import 'package:freelance_app/models/reviewDTO.dart';
import 'package:freelance_app/services/review_service.dart';

class FreelancerReviewsScreen extends StatefulWidget {
  final int freelancerId;

  const FreelancerReviewsScreen({required this.freelancerId, super.key});

  @override
  _FreelancerReviewsScreenState createState() => _FreelancerReviewsScreenState();
}

class _FreelancerReviewsScreenState extends State<FreelancerReviewsScreen> {
  late Future<List<ReviewDTO>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewService().getDetailedReviewsForUser(widget.freelancerId);
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.grey, size: 16);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Reviews"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 154, 175, 136),
      ),
      body: FutureBuilder<List<ReviewDTO>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Failed to load reviews", style: TextStyle(color: Colors.red[700])));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No reviews yet", style: TextStyle(fontSize: 18, color: Colors.black54)));
          } else {
            final reviews = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color.fromARGB(255, 129, 158, 136),
                          child: Text(
                            review.reviewerName.isNotEmpty ? review.reviewerName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.jobTitle,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "by ${review.reviewerName}",
                                style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 8),
                              _buildStarRating(review.rating),
                              const SizedBox(height: 12),
                              Text(
                                review.feedback,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                review.reviewTime.split('T').first,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
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
