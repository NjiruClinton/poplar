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

  Future<void> syncRestrictedNumbers();
}
