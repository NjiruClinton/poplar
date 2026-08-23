class RejectedCall {
  const RejectedCall({
    required this.phoneNumber,
    this.contactName,
    required this.timestamp,
  });
  final String phoneNumber;
  final String? contactName;
  final DateTime timestamp;

  factory RejectedCall.fromJson(Map<String, dynamic> json) => RejectedCall(
    phoneNumber: json['phoneNumber'] as String,
    contactName: json['contactName'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'contactName': contactName,
    'timestamp': timestamp.toIso8601String(),
  };
}
