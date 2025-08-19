class Job {
  final int? id;
  final String title;
  final String description;
  final double budget;
  final String deadline;
  final String skills;
  final int clientId;

  Job({
    this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.deadline,
    required this.skills,
    required this.clientId,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        budget: (json['budget'] as num).toDouble(),
        deadline: json['deadline'],
        skills: json['skills'],
        clientId: json['client']['id'],  // Note nested client id
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'budget': budget,
        'deadline': deadline,
        'skills': skills,
        'client': {'id': clientId},  // Nested client object
      };
       /// Minimal JSON with just job id for wishlist or references
  Map<String, dynamic> toMinimalJson() => {
        'id': id,
      };
}
