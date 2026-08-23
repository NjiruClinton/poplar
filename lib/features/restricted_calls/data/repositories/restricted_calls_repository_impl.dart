import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/rejected_call.dart';
import '../../domain/entities/restricted_contact.dart';
import '../../domain/repositories/restricted_calls_repository.dart';

@LazySingleton(as: RestrictedCallsRepository)
class RestrictedCallsRepositoryImpl implements RestrictedCallsRepository {
  static const String _restrictedContactsKey = 'restricted_contacts';

  static const String _rejectedCallsKey = 'rejected_calls';

  final SharedPreferences preferences;

  RestrictedCallsRepositoryImpl(this.preferences);

  @override
  Future<List<RestrictedContact>> getRestrictedContacts() async {
    final values = preferences.getStringList(_restrictedContactsKey) ?? [];

    return values
        .map(
          (value) => RestrictedContact.fromJson(
            jsonDecode(value) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> addRestrictedContact(RestrictedContact contact) async {
    final contacts = await getRestrictedContacts();

    final updatedContacts = [
      ...contacts.where((item) => item.phoneNumber != contact.phoneNumber),
      contact,
    ];

    await preferences.setStringList(
      _restrictedContactsKey,
      updatedContacts.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  @override
  Future<void> removeRestrictedContact(String phoneNumber) async {
    final contacts = await getRestrictedContacts();

    final updatedContacts = contacts
        .where((item) => item.phoneNumber != phoneNumber)
        .toList();

    await preferences.setStringList(
      _restrictedContactsKey,
      updatedContacts.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  @override
  Future<List<RejectedCall>> getRejectedCalls() async {
    final values = preferences.getStringList(_rejectedCallsKey) ?? [];

    return values
        .map(
          (value) =>
              RejectedCall.fromJson(jsonDecode(value) as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> logRejectedCall(RejectedCall call) async {
    final calls = await getRejectedCalls();

    final updatedCalls = [call, ...calls];

    await preferences.setStringList(
      _rejectedCallsKey,
      updatedCalls.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}
