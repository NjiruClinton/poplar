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
    bool rejectAllCalls = false,
    bool allowOnlySelected = false,
    List<RestrictedContact> allowedContacts = const [],
  }) => RestrictedCallsLoaded(
    contacts: contacts,
    rejectedCalls: rejectedCalls,
    blockUnknownCallers: blockUnknownCallers,
    isUpdating: isUpdating,
    rejectAllCalls: rejectAllCalls,
    allowOnlySelected: allowOnlySelected,
    allowedContacts: allowedContacts,
  );
  const factory RestrictedCallsState.error(String message) =
      RestrictedCallsError;

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(
      List<RestrictedContact>,
      List<RejectedCall>,
      bool,
      bool,
      bool,
      bool,
      List<RestrictedContact>,
    ) loaded,
    required T Function(String) error,
  }) => switch (this) {
    RestrictedCallsInitial() => initial(),
    RestrictedCallsLoading() => loading(),
    RestrictedCallsLoaded(
      :final contacts,
      :final rejectedCalls,
      :final blockUnknownCallers,
      :final isUpdating,
      :final rejectAllCalls,
      :final allowOnlySelected,
      :final allowedContacts,
    ) =>
      loaded(
        contacts,
        rejectedCalls,
        blockUnknownCallers,
        isUpdating,
        rejectAllCalls,
        allowOnlySelected,
        allowedContacts,
      ),
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
    this.rejectAllCalls = false,
    this.allowOnlySelected = false,
    this.allowedContacts = const [],
  });
  final List<RestrictedContact> contacts;
  final List<RejectedCall> rejectedCalls;
  final bool blockUnknownCallers;
  final bool isUpdating;
  final bool rejectAllCalls;
  final bool allowOnlySelected;
  final List<RestrictedContact> allowedContacts;
}

final class RestrictedCallsError extends RestrictedCallsState {
  const RestrictedCallsError(this.message);
  final String message;
}
