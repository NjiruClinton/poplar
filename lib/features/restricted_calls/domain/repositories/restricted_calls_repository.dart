import '../entities/rejected_call.dart';
import '../entities/restricted_contact.dart';

abstract class RestrictedCallsRepository {
  Future<List<RestrictedContact>> getRestrictedContacts();

  Future<void> addRestrictedContact(RestrictedContact contact);

  Future<void> addRestrictedContacts(List<RestrictedContact> contacts);

  Future<void> removeRestrictedContact(String phoneNumber);

  Future<List<RejectedCall>> getRejectedCalls();

  Future<void> clearRejectedCalls();

  Future<bool> getBlockUnknownCallers();

  Future<void> setBlockUnknownCallers(bool enabled);

  Future<bool> getRejectAllCalls();

  Future<void> setRejectAllCalls(bool enabled);

  Future<bool> getAllowOnlySelected();

  Future<void> setAllowOnlySelected(bool enabled);

  Future<List<RestrictedContact>> getAllowedContacts();

  Future<void> addAllowedContacts(List<RestrictedContact> contacts);

  Future<void> removeAllowedContact(String phoneNumber);

  Future<void> syncRestrictedNumbers();
}
