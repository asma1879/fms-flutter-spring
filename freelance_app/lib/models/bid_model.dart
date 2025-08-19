import 'package:flutter/material.dart';
import 'package:freelance_app/models/job_model.dart';

class Bid {
  final int? id;
  final double amount;
  final String proposalMessage;
  final String? bidTime;
  final int freelancerId;
  final int jobId;
  String? status; // e.g., "PENDING", "ACCEPTED", "REJECTED"
  String? deliveryStatus; // "NOT_DELIVERED", "DELIVERED"
  String? deliveryLink; // ✅ Optional delivery link
  String? deliveryTime; // ✅ Optional delivery timestamp
  Job? job; // ✅ Optional Job object
  final String? freelancerName;
  final String? jobTitle;
  bool isPaidToFreelancer;

  Bid({
    this.id,
    required this.amount,
    required this.proposalMessage,
    this.bidTime,
    required this.freelancerId,
    required this.jobId,
    this.status,
    this.deliveryStatus,
    this.deliveryLink,
    this.deliveryTime,
    this.job,
    this.freelancerName,
    this.jobTitle,
    this.isPaidToFreelancer = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'proposalMessage': proposalMessage,
        'status': status,
        'deliveryStatus': deliveryStatus,
        'deliveryLink': deliveryLink,
        'deliveryTime': deliveryTime,
        'freelancer': {'id': freelancerId},
        'job': {'id': jobId},
        'freelancerName': freelancerName,
        'jobTitle': jobTitle,
        'isPaidToFreelancer': isPaidToFreelancer,
      };
  factory Bid.fromJson(Map<String, dynamic> json) {
  // Extract job info safely
  Job? jobObj;
  String jobTitle = 'Unknown Job';

  if (json.containsKey('job') && json['job'] != null) {
    jobObj = Job.fromJson(json['job']);
    jobTitle = jobObj.title ?? 'Unknown Job';
  } else if (json['jobTitle'] != null) {
    jobTitle = json['jobTitle'];
  } else {
    debugPrint("Warning: bid ${json['id']} has no job info!");
  }

  return Bid(
    id: json['id'],
    amount: (json['amount'] as num).toDouble(),
    proposalMessage: json['proposalMessage'],
    bidTime: json['bidTime'],
    freelancerId: json['freelancer'] != null ? json['freelancer']['id'] : 0,
    jobId: json['job'] != null ? json['job']['id'] : 0,
    status: json['status'],
    deliveryStatus: json['deliveryStatus'],
    deliveryLink: json['deliveryLink'],
    deliveryTime: json['deliveryTime'],
    job: jobObj,
    //: json['freelancer'] != null ? json['freelancer']['name'] : null,
    
    freelancerName: json['freelancer'] != null ? json['freelancer']['name'] : json['freelancerName'],
    jobTitle: jobTitle,
    isPaidToFreelancer: json['isPaidToFreelancer'] ?? false,
  );
}

}