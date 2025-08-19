class WithdrawalRequest {
  final int? id;
  final int freelancerId;
  final String method;
  final String accountInfo;
  final double amount;
  final String status;
  final DateTime requestDate;

  WithdrawalRequest({
    this.id,
    required this.freelancerId,
    required this.method,
    required this.accountInfo,
    required this.amount,
    this.status = "COMPLETED",
    required this.requestDate,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'],
      freelancerId: json['freelancerId'],
      method: json['method'],
      accountInfo: json['accountInfo'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      requestDate: DateTime.parse(json['requestDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'freelancerId': freelancerId,
      'method': method,
      'accountInfo': accountInfo,
      'amount': amount,
      'status': status,
      'requestDate': requestDate.toIso8601String(),
    };
  }
}
