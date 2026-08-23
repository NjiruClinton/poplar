class RestrictedContact {
  const RestrictedContact({
    required this.phoneNumber,
    this.name,
    required this.createdAt,
  });
  final String phoneNumber;
  final String? name;
  final DateTime createdAt;

  factory RestrictedContact.fromJson(Map<String, dynamic> json) =>
      RestrictedContact(
        phoneNumber: json['phoneNumber'] as String,
        name: json['name'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };
}
