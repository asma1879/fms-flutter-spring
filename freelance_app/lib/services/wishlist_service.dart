import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wishlist_model.dart';

class WishlistService {
  final String baseUrl = 'http://localhost:8080/api/auth/wishlist'; // Change if needed

  Future<List<Wishlist>> getWishlistByUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));  // fixed path

    if (response.statusCode == 200) {
      final List<dynamic> wishlistJson = json.decode(response.body);
      return wishlistJson.map((json) => Wishlist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  Future<Wishlist> addToWishlist(Wishlist wishlist) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),  // fixed path
      headers: {'Content-Type': 'application/json'},
      body: json.encode(wishlist.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Wishlist.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add to wishlist');
    }
  }

  Future<void> deleteWishlist(int wishlistId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$wishlistId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete from wishlist');
    }
  }
}
