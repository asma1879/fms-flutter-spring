class ReviewDTO {
  final int id;
  final int rating;
  final String feedback;
  final String reviewerName;  // generic name, works for both
  final String jobTitle;
  final String reviewTime;

  ReviewDTO({
    required this.id,
    required this.rating,
    required this.feedback,
    required this.reviewerName,
    required this.jobTitle,
    required this.reviewTime,
  });

  factory ReviewDTO.fromJson(Map<String, dynamic> json) {
    return ReviewDTO(
      id: json['id'],
      rating: json['rating'],
      feedback: json['feedback'] ?? '',
      reviewerName: json['reviewerName'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      reviewTime: json['reviewTime'] ?? '',
    );
  }
}
