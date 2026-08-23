import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/restricted_contact.dart';

part 'restricted_calls_event.freezed.dart';

@freezed
class RestrictedCallsEvent with _$RestrictedCallsEvent {
  const factory RestrictedCallsEvent.load() = LoadRestrictedCalls;

  const factory RestrictedCallsEvent.add(RestrictedContact contact) =
      AddRestrictedContact;

  const factory RestrictedCallsEvent.remove(String phoneNumber) =
      RemoveRestrictedContact;
}
