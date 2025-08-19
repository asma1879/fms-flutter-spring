class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String role;
  final double walletBalance;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.walletBalance = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: '', // don't return password
      role: json['role'] ?? '',
       walletBalance: (json['walletBalance'] ?? 0.0).toDouble(),
  
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'walletBalance': walletBalance,
      };
}
