import '../entities/rejected_call.dart';
import '../entities/restricted_contact.dart';

abstract class RestrictedCallsRepository {
  Future<List<RestrictedContact>> getRestrictedContacts();

  Future<void> addRestrictedContact(RestrictedContact contact);

  Future<void> removeRestrictedContact(String phoneNumber);

  Future<List<RejectedCall>> getRejectedCalls();

  // Future<void> logRejectedCall(RejectedCall call);

  Future<void> syncRestrictedNumbers();
}
