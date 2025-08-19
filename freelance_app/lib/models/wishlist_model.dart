import 'package:freelance_app/models/job_model.dart';

class Wishlist {
  final int? id;
  final Job job;
  final int userId;

  Wishlist({
    this.id,
    required this.job,
    required this.userId,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['id'],
      job: Job.fromJson(json['job']),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'job': job.toMinimalJson(), // <-- minimal JSON here
      'userId': userId,
    };
  }
}
