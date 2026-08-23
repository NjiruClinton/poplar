import 'package:freezed_annotation/freezed_annotation.dart';

part 'restricted_contact.freezed.dart';
part 'restricted_contact.g.dart';

@freezed
abstract class RestrictedContact with _$RestrictedContact {
  const factory RestrictedContact({
    required String phoneNumber,
    String? name,
    required DateTime createdAt,
  }) = _RestrictedContact;

  factory RestrictedContact.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$RestrictedContactFromJson(json);
}