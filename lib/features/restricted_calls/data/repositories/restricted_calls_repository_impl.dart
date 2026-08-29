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
  static const String _rejectAllCallsKey = 'reject_all_calls';
  static const String _allowOnlySelectedKey = 'allow_only_selected';
  static const String _allowedContactsKey = 'allowed_contacts';

  final SharedPreferences preferences;
  final CallScreeningPlatform callScreeningPlatform;

  RestrictedCallsRepositoryImpl(this.preferences, this.callScreeningPlatform);

  @override
  Future<List<RestrictedContact>> getRestrictedContacts() async {
    return _getContacts(_restrictedContactsKey);
  }

  Future<List<RestrictedContact>> _getContacts(String key) async {
    final values = preferences.getStringList(key) ?? [];

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
        contactName:
            call['contactName'] as String? ??
            names[call['phoneNumber'] as String],
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
    await _syncPolicy();
  }

  @override
  Future<bool> getRejectAllCalls() async =>
      preferences.getBool(_rejectAllCallsKey) ?? false;

  @override
  Future<void> setRejectAllCalls(bool enabled) async {
    await preferences.setBool(_rejectAllCallsKey, enabled);
    if (enabled) {
      await preferences.setBool(_allowOnlySelectedKey, false);
    }
    await _syncPolicy();
  }

  @override
  Future<bool> getAllowOnlySelected() async =>
      preferences.getBool(_allowOnlySelectedKey) ?? false;

  @override
  Future<void> setAllowOnlySelected(bool enabled) async {
    await preferences.setBool(_allowOnlySelectedKey, enabled);
    if (enabled) {
      await preferences.setBool(_rejectAllCallsKey, false);
    }
    await _syncPolicy();
  }

  @override
  Future<List<RestrictedContact>> getAllowedContacts() =>
      _getContacts(_allowedContactsKey);

  @override
  Future<void> addAllowedContacts(List<RestrictedContact> contacts) async {
    if (contacts.isEmpty) return;
    final existing = await getAllowedContacts();
    final byNumber = <String, RestrictedContact>{
      for (final contact in existing) contact.phoneNumber: contact,
      for (final contact in contacts) contact.phoneNumber: contact,
    };
    await _saveAllowedContacts(byNumber.values.toList());
  }

  @override
  Future<void> removeAllowedContact(String phoneNumber) async {
    final contacts = await getAllowedContacts();
    await _saveAllowedContacts(
      contacts.where((item) => item.phoneNumber != phoneNumber).toList(),
    );
  }

  Future<void> _saveAllowedContacts(List<RestrictedContact> contacts) async {
    await preferences.setStringList(
      _allowedContactsKey,
      contacts.map((item) => jsonEncode(item.toJson())).toList(),
    );
    await _syncPolicy();
  }

  Future<void> _syncPolicy() async {
    final allowed = await getAllowedContacts();
    await callScreeningPlatform.setBlockingPolicy(
      blockUnknownCallers: await getBlockUnknownCallers(),
      rejectAllCalls: await getRejectAllCalls(),
      allowOnlySelected: await getAllowOnlySelected(),
      allowedNumbers: allowed.map((item) => item.phoneNumber).toList(),
    );
  }

  @override
  Future<void> syncRestrictedNumbers() async {
    final contacts = await getRestrictedContacts();

    await callScreeningPlatform.setRestrictedNumbers(
      contacts.map((item) => item.phoneNumber).toList(),
    );
    await _syncPolicy();
  }
}
