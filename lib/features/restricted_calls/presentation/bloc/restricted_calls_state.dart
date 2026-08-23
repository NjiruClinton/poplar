import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/rejected_call.dart';
import '../../domain/entities/restricted_contact.dart';

part 'restricted_calls_state.freezed.dart';

@freezed
class RestrictedCallsState with _$RestrictedCallsState {
  const factory RestrictedCallsState.initial() =
  RestrictedCallsInitial;

  const factory RestrictedCallsState.loading() =
  RestrictedCallsLoading;

  const factory RestrictedCallsState.loaded({
    @Default([])
    List<RestrictedContact> contacts,
    @Default([])
    List<RejectedCall> rejectedCalls,
  }) = RestrictedCallsLoaded;

  const factory RestrictedCallsState.error(
      String message,
      ) = RestrictedCallsError;
}