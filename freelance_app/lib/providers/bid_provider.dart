import 'package:flutter/material.dart';
import '../models/bid_model.dart';
import '../services/bid_service.dart';

class BidProvider with ChangeNotifier {
  final BidService _service = BidService();

  List<Bid> _bids = [];
  List<Bid> _acceptedBids = [];
  List<Bid> _deliveredBids = [];  // new list for delivered bids

  List<Bid> get bids => _bids;
  List<Bid> get acceptedBids => _acceptedBids;
  List<Bid> get deliveredBids => _deliveredBids; // getter for delivered bids

  Future<void> loadBids(int jobId) async {
    try {
      _bids = await _service.getBidsByJob(jobId);
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to load bids: $e");
    }
  }

  Future<bool> submitBid(Bid bid) async {
    final success = await _service.applyBid(bid);
    if (success) {
      _bids.add(bid);
      notifyListeners();
    }
    return success;
  }

  Future<bool> changeBidStatus(int bidId, String status) async {
    final success = await _service.updateBidStatus(bidId, status);
    if (success) {
      final index = _bids.indexWhere((b) => b.id == bidId);
      if (index != -1) {
        _bids[index].status = status;
        notifyListeners();
      }
    }
    return success;
  }

  Future<void> loadAcceptedBids(int freelancerId) async {
    try {
      _acceptedBids = await _service.getAcceptedBidsForFreelancer(freelancerId);
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to load accepted bids: $e");
    }
  }

  // Future<bool> deliverJob(int bidId) async {
  //   final success = await _service.deliverJob(bidId);
  //   if (success) {
  //     final index = _acceptedBids.indexWhere((b) => b.id == bidId);
  //     if (index != -1) {
  //       _acceptedBids[index].deliveryStatus = "DELIVERED";
  //       notifyListeners();
  //     }
  //   }
  //   return success;
  // }

  Future<bool> deliverJob(int bidId, {String? deliveryLink}) async {
  final success = await _service.deliverJob(
    bidId,
    deliveryLink: deliveryLink, // pass as named param
  );

  if (success) {
    final index = _acceptedBids.indexWhere((b) => b.id == bidId);
    if (index != -1) {
      _acceptedBids[index].deliveryStatus = "DELIVERED";
      _acceptedBids[index].deliveryLink = deliveryLink; // store locally
      notifyListeners();
    }
  }
  return success;
}



  // NEW: Load delivered bids for a client
  Future<void> loadDeliveredBids(int clientId) async {
    try {
      _deliveredBids = await _service.getDeliveredBidsForClient(clientId);
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to load delivered bids: $e");
    }
  }

  // NEW: Confirm payment for a bid
  Future<bool> confirmBidPayment(int bidId) async {
    final success = await _service.confirmPayment(bidId);
    if (success) {
      // Update local delivered bids list to reflect payment
      final index = _deliveredBids.indexWhere((b) => b.id == bidId);
      if (index != -1) {
        _deliveredBids[index].status = "PAID";
        notifyListeners();
      }
    }
    return success;
  }
    // NEW: Accept bid and hold funds in system account
  Future<bool> acceptBidAndHoldFunds(int bidId) async {
    final success = await _service.acceptBid(bidId);
    if (success) {
      final index = _bids.indexWhere((b) => b.id == bidId);
      if (index != -1) {
        _bids[index].status = "ACCEPTED";
        notifyListeners();
      }
    }
    return success;
  }
    // NEW: Release payment from system to freelancer
  Future<bool> releasePaymentToFreelancer(int bidId) async {
    final success = await _service.confirmPayment(bidId);
    if (success) {
      final index = _bids.indexWhere((b) => b.id == bidId);
      if (index != -1) {
        _bids[index].status = "PAID";
        notifyListeners();
      }

      // Optional: also update delivered bids list if present
      final deliveredIndex = _deliveredBids.indexWhere((b) => b.id == bidId);
      if (deliveredIndex != -1) {
        _deliveredBids[deliveredIndex].status = "PAID";
        notifyListeners();
      }
    }
    return success;
  }
  Future<void> loadAllBidsForFreelancer(int freelancerId) async {
  try {
    _bids = await _service.getBidsByFreelancer(freelancerId);
    notifyListeners();
  } catch (e) {
    debugPrint("Failed to load all bids: $e");
  }
}

}
