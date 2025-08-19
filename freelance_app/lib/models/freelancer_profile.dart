class FreelancerProfile {
  int? id;
  int userId;
  String? title;
  String? overview;
  String? skills;
  String? education;
  String? experience;
  String? hourlyRate;
  String? profileImageUrl;

  FreelancerProfile({
    this.id,
    required this.userId,
    this.title,
    this.overview,
    this.skills,
    this.education,
    this.experience,
    this.hourlyRate,
    this.profileImageUrl,
  });

  factory FreelancerProfile.fromJson(Map<String, dynamic> json) => FreelancerProfile(
        id: json['id'],
        userId: json['userId'],
        title: json['title'],
        overview: json['overview'],
        skills: json['skills'],
        education: json['education'],
        experience: json['experience'],
        hourlyRate: json['hourlyRate'],
        profileImageUrl: json['profileImageUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'overview': overview,
        'skills': skills,
        'education': education,
        'experience': experience,
        'hourlyRate': hourlyRate,
        'profileImageUrl': profileImageUrl,
      };
}
