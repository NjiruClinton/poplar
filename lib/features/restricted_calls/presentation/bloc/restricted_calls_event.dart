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
  const factory RestrictedCallsEvent.setRejectAll(bool enabled) =
      SetRejectAllCalls;
  const factory RestrictedCallsEvent.setAllowOnlySelected(bool enabled) =
      SetAllowOnlySelected;
  const factory RestrictedCallsEvent.addAllowed(
    List<RestrictedContact> contacts,
  ) = AddAllowedContacts;
  const factory RestrictedCallsEvent.removeAllowed(String phoneNumber) =
      RemoveAllowedContact;
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

final class SetRejectAllCalls extends RestrictedCallsEvent {
  const SetRejectAllCalls(this.enabled);
  final bool enabled;
}

final class SetAllowOnlySelected extends RestrictedCallsEvent {
  const SetAllowOnlySelected(this.enabled);
  final bool enabled;
}

final class AddAllowedContacts extends RestrictedCallsEvent {
  const AddAllowedContacts(this.contacts);
  final List<RestrictedContact> contacts;
}

final class RemoveAllowedContact extends RestrictedCallsEvent {
  const RemoveAllowedContact(this.phoneNumber);
  final String phoneNumber;
}
