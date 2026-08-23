import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/rejected_call.dart';
import '../../domain/entities/restricted_contact.dart';
import '../../domain/repositories/restricted_calls_repository.dart';
import '../../../../core/platform/call_screening_platform.dart';

@LazySingleton(as: RestrictedCallsRepository)
class RestrictedCallsRepositoryImpl implements RestrictedCallsRepository {
  static const String _restrictedContactsKey = 'restricted_contacts';

  static const String _blockUnknownCallersKey = 'block_unknown_callers';

  final SharedPreferences preferences;
  final CallScreeningPlatform callScreeningPlatform;

  RestrictedCallsRepositoryImpl(this.preferences, this.callScreeningPlatform);

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
    await addRestrictedContacts([contact]);
  }

  @override
  Future<void> addRestrictedContacts(List<RestrictedContact> contacts) async {
    if (contacts.isEmpty) return;

    final existing = await getRestrictedContacts();
    final byNumber = <String, RestrictedContact>{
      for (final contact in existing) contact.phoneNumber: contact,
      for (final contact in contacts) contact.phoneNumber: contact,
    };
    final updatedContacts = byNumber.values.toList();

    await preferences.setStringList(
      _restrictedContactsKey,
      updatedContacts.map((item) => jsonEncode(item.toJson())).toList(),
    );

    await callScreeningPlatform.setRestrictedNumbers(
      updatedContacts.map((item) => item.phoneNumber).toList(),
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

    await callScreeningPlatform.setRestrictedNumbers(
      updatedContacts.map((item) => item.phoneNumber).toList(),
    );
  }

  @override
  Future<List<RejectedCall>> getRejectedCalls() async {
    final calls = await callScreeningPlatform.getRejectedCalls();

    final contacts = await getRestrictedContacts();
    final names = {for (final item in contacts) item.phoneNumber: item.name};
    final result = calls.map((call) {
      return RejectedCall(
        phoneNumber: call['phoneNumber'] as String,
        contactName: names[call['phoneNumber'] as String],
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          call['timestamp'] as int,
        ),
      );
    }).toList();
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return result;
  }

  @override
  Future<void> clearRejectedCalls() =>
      callScreeningPlatform.clearRejectedCalls();

  @override
  Future<bool> getBlockUnknownCallers() async =>
      preferences.getBool(_blockUnknownCallersKey) ?? false;

  @override
  Future<void> setBlockUnknownCallers(bool enabled) async {
    await preferences.setBool(_blockUnknownCallersKey, enabled);
    await callScreeningPlatform.setBlockingPolicy(blockUnknownCallers: enabled);
  }

  @override
  Future<void> syncRestrictedNumbers() async {
    final contacts = await getRestrictedContacts();

    await callScreeningPlatform.setRestrictedNumbers(
      contacts.map((item) => item.phoneNumber).toList(),
    );
    await callScreeningPlatform.setBlockingPolicy(
      blockUnknownCallers: await getBlockUnknownCallers(),
    );
  }
}
