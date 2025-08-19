class Review {
  final int? id;
  final int reviewerId;
  final int revieweeId;
  final int jobId;
  final int rating;
  final String feedback;
  final String? reviewTime;

  Review({
    this.id,
    required this.reviewerId,
    required this.revieweeId,
    required this.jobId,
    required this.rating,
    required this.feedback,
    this.reviewTime,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    reviewerId: json['reviewerId'],
    revieweeId: json['revieweeId'],
    jobId: json['jobId'],
    rating: json['rating'],
    feedback: json['feedback'],
    reviewTime: json['reviewTime'],
  );

  Map<String, dynamic> toJson() => {
    'reviewerId': reviewerId,
    'revieweeId': revieweeId,
    'jobId': jobId,
    'rating': rating,
    'feedback': feedback,
  };
}
