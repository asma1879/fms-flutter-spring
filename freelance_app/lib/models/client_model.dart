class Client {
  int id;
  String name;
  String email;
  double walletBalance;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.walletBalance,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    walletBalance: json['walletBalance']?.toDouble() ?? 0.0,
  );
}
