import '../../domain/entities/rejected_call.dart';
import '../../domain/entities/restricted_contact.dart';

sealed class RestrictedCallsState {
  const RestrictedCallsState();
  const factory RestrictedCallsState.initial() = RestrictedCallsInitial;
  const factory RestrictedCallsState.loading() = RestrictedCallsLoading;
  factory RestrictedCallsState.loaded({
    List<RestrictedContact> contacts = const [],
    List<RejectedCall> rejectedCalls = const [],
    bool blockUnknownCallers = false,
    bool isUpdating = false,
  }) => RestrictedCallsLoaded(
    contacts: contacts,
    rejectedCalls: rejectedCalls,
    blockUnknownCallers: blockUnknownCallers,
    isUpdating: isUpdating,
  );
  const factory RestrictedCallsState.error(String message) =
      RestrictedCallsError;

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<RestrictedContact>, List<RejectedCall>, bool, bool)
    loaded,
    required T Function(String) error,
  }) => switch (this) {
    RestrictedCallsInitial() => initial(),
    RestrictedCallsLoading() => loading(),
    RestrictedCallsLoaded(
      :final contacts,
      :final rejectedCalls,
      :final blockUnknownCallers,
      :final isUpdating,
    ) =>
      loaded(contacts, rejectedCalls, blockUnknownCallers, isUpdating),
    RestrictedCallsError(:final message) => error(message),
  };
}

final class RestrictedCallsInitial extends RestrictedCallsState {
  const RestrictedCallsInitial();
}

final class RestrictedCallsLoading extends RestrictedCallsState {
  const RestrictedCallsLoading();
}

final class RestrictedCallsLoaded extends RestrictedCallsState {
  const RestrictedCallsLoaded({
    this.contacts = const [],
    this.rejectedCalls = const [],
    this.blockUnknownCallers = false,
    this.isUpdating = false,
  });
  final List<RestrictedContact> contacts;
  final List<RejectedCall> rejectedCalls;
  final bool blockUnknownCallers;
  final bool isUpdating;
}

final class RestrictedCallsError extends RestrictedCallsState {
  const RestrictedCallsError(this.message);
  final String message;
}
