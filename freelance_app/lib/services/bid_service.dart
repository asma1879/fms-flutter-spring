import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/bid_model.dart';

class BidService {
  final String baseUrl = "http://localhost:8080/api/auth/bids";

  // ✅ Apply a bid to a job
  Future<bool> applyBid(Bid bid) async {
    final url = Uri.parse(
        '$baseUrl/apply?freelancerId=${bid.freelancerId}&jobId=${bid.jobId}');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(bid.toJson()),
    );

    return response.statusCode == 200;
  }

  // ✅ Get all bids for a job
  Future<List<Bid>> getBidsByJob(int jobId) async {
    final url = Uri.parse('$baseUrl/job/$jobId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Bid.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load bids');
    }
  }

  // ✅ Update bid status (ACCEPTED, REJECTED)
  Future<bool> updateBidStatus(int bidId, String status) async {
    final response =
        await http.post(Uri.parse('$baseUrl/$bidId/status?status=$status'));

    return response.statusCode == 200;
  }

  // ✅ Accept bid and hold funds (escrow)
  Future<bool> acceptBid(int bidId) async {
    final response = await http.post(Uri.parse('$baseUrl/$bidId/accept'));
    return response.statusCode == 200;
  }

  // ✅ Confirm payment and release to freelancer
  Future<bool> confirmPayment(int bidId) async {
    final response =
        await http.post(Uri.parse('$baseUrl/$bidId/confirm-payment'));
    return response.statusCode == 200;
  }

  // ✅ Get accepted bids for freelancer
  Future<List<Bid>> getAcceptedBidsForFreelancer(int freelancerId) async {
    final url =
        Uri.parse('$baseUrl/freelancer/$freelancerId/my-jobs');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Bid.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load accepted jobs');
    }
  }

  // ✅ Deliver job
  // Future<bool> deliverJob(int bidId) async {
  //   final url = Uri.parse('$baseUrl/$bidId/deliver');
  //   final response = await http.post(url);

  //   return response.statusCode == 200;
  // }

  Future<bool> deliverJob(int bidId, {String? deliveryLink}) async {
  final url = Uri.parse('$baseUrl/$bidId/deliver');
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: deliveryLink != null ? jsonEncode({"deliveryLink": deliveryLink}) : null,
  );
  return response.statusCode == 200;
}


  // ✅ Get delivered bids for a client
  Future<List<Bid>> getDeliveredBidsForClient(int clientId) async {
    final url = Uri.parse('$baseUrl/client/$clientId/delivered');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Bid.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load delivered jobs');
    }
  }

// ✅ Get all bids submitted by a freelancer
Future<List<Bid>> getBidsByFreelancer(int freelancerId) async {
  final url = Uri.parse('$baseUrl/freelancer/$freelancerId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    final bids = data.map((item) => Bid.fromJson(item)).toList();

    // 🔹 Print each bid's job info
    for (var bid in bids) {
      debugPrint(
        'Bid ID: ${bid.id}, Job ID: ${bid.jobId}, Job Title: ${bid.job?.title ?? bid.jobTitle ?? "Unknown"}'
      );
    }

    return bids;
  } else {
    throw Exception('Failed to load bids');
  }
}

 

Future<Map<String, int>> getBidOverview(int freelancerId) async {
  final url = Uri.parse('$baseUrl/$freelancerId/overview');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    // Convert dynamic values to int
    return data.map((key, value) => MapEntry(key, (value as num).toInt()));
  } else {
    throw Exception('Failed to load bid overview');
  }
}

}
