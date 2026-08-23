import '../../domain/entities/restricted_contact.dart';

sealed class RestrictedCallsEvent {
  const RestrictedCallsEvent();
  const factory RestrictedCallsEvent.load() = LoadRestrictedCalls;
  const factory RestrictedCallsEvent.add(RestrictedContact contact) =
      AddRestrictedContact;
  const factory RestrictedCallsEvent.addMany(List<RestrictedContact> contacts) =
      AddManyRestrictedContacts;
  const factory RestrictedCallsEvent.remove(String phoneNumber) =
      RemoveRestrictedContact;
  const factory RestrictedCallsEvent.setBlockUnknown(bool enabled) =
      SetBlockUnknownCallers;
  const factory RestrictedCallsEvent.clearLogs() = ClearRejectedCallLogs;
}

final class LoadRestrictedCalls extends RestrictedCallsEvent {
  const LoadRestrictedCalls();
}

final class AddRestrictedContact extends RestrictedCallsEvent {
  const AddRestrictedContact(this.contact);
  final RestrictedContact contact;
}

final class AddManyRestrictedContacts extends RestrictedCallsEvent {
  const AddManyRestrictedContacts(this.contacts);
  final List<RestrictedContact> contacts;
}

final class RemoveRestrictedContact extends RestrictedCallsEvent {
  const RemoveRestrictedContact(this.phoneNumber);
  final String phoneNumber;
}

final class SetBlockUnknownCallers extends RestrictedCallsEvent {
  const SetBlockUnknownCallers(this.enabled);
  final bool enabled;
}

final class ClearRejectedCallLogs extends RestrictedCallsEvent {
  const ClearRejectedCallLogs();
}
