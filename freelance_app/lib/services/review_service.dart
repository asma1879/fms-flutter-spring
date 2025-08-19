import 'dart:convert';
import 'package:freelance_app/models/reviewDTO.dart';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';

class ReviewService {
  final String baseUrl = 'http://localhost:8080/api/auth/reviews';

  Future<bool> submitReview(Review review) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(review.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<List<Review>> getReviewsForUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/reviewee/$userId'));
    if (response.statusCode == 200) {
      Iterable data = jsonDecode(response.body);
      return data.map((e) => Review.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load reviews");
    }
  }
  Future<List<ReviewDTO>> getDetailedReviewsForUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/detailed/reviewee/$userId'));
    if (response.statusCode == 200) {
      Iterable data = jsonDecode(response.body);
      return data.map((e) => ReviewDTO.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load detailed reviews");
    }
  }
   Future<List<ReviewDTO>> getDetailedReviewsForClient(int clientId) async {
    final response = await http.get(Uri.parse('$baseUrl/detailed/client/$clientId'));
    if (response.statusCode == 200) {
      Iterable data = jsonDecode(response.body);
      return data.map((e) => ReviewDTO.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load detailed client reviews");
    }
  }
}
