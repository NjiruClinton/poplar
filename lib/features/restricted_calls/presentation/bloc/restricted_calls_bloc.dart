import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/restricted_calls_repository.dart';
import 'restricted_calls_event.dart';
import 'restricted_calls_state.dart';

@injectable
class RestrictedCallsBloc
    extends Bloc<RestrictedCallsEvent, RestrictedCallsState> {
  final RestrictedCallsRepository repository;

  RestrictedCallsBloc(this.repository)
    : super(const RestrictedCallsState.initial()) {
    on<LoadRestrictedCalls>(_onLoad);
    on<AddRestrictedContact>(_onAdd);
    on<AddManyRestrictedContacts>(_onAddMany);
    on<RemoveRestrictedContact>(_onRemove);
    on<SetBlockUnknownCallers>(_onSetBlockUnknown);
    on<ClearRejectedCallLogs>(_onClearLogs);
    on<SetRejectAllCalls>(_onSetRejectAll);
    on<SetAllowOnlySelected>(_onSetAllowOnlySelected);
    on<AddAllowedContacts>(_onAddAllowed);
    on<RemoveAllowedContact>(_onRemoveAllowed);
  }

  Future<void> _onLoad(
    LoadRestrictedCalls event,
    Emitter<RestrictedCallsState> emit,
  ) async {
    emit(const RestrictedCallsState.loading());

    try {
      final contacts = await repository.getRestrictedContacts();

      await repository.syncRestrictedNumbers();

      final rejectedCalls = await repository.getRejectedCalls();
      final blockUnknownCallers = await repository.getBlockUnknownCallers();
      final rejectAllCalls = await repository.getRejectAllCalls();
      final allowOnlySelected = await repository.getAllowOnlySelected();
      final allowedContacts = await repository.getAllowedContacts();

      emit(
        RestrictedCallsState.loaded(
          contacts: contacts,
          rejectedCalls: rejectedCalls,
          blockUnknownCallers: blockUnknownCallers,
          rejectAllCalls: rejectAllCalls,
          allowOnlySelected: allowOnlySelected,
          allowedContacts: allowedContacts,
        ),
      );
    } catch (error) {
      emit(RestrictedCallsState.error(error.toString()));
    }
  }

  Future<void> _onAddMany(
    AddManyRestrictedContacts event,
    Emitter<RestrictedCallsState> emit,
  ) async {
    await repository.addRestrictedContacts(event.contacts);
    add(const RestrictedCallsEvent.load());
  }

  Future<void> _onAdd(
    AddRestrictedContact event,
    Emitter<RestrictedCallsState> emit,
  ) async {
    await repository.addRestrictedContact(event.contact);

    add(const RestrictedCallsEvent.load());
  }

  Future<void> _onRemove(
    RemoveRestrictedContact event,
    Emitter<RestrictedCallsState> emit,
  ) async {
    await repository.removeRestrictedContact(event.phoneNumber);

    add(const RestrictedCallsEvent.load());
  }

  Future<void> _onSetBlockUnknown(
    SetBlockUnknownCallers event,
    Emitter<RestrictedCallsState> emit,
  ) async {
    await repository.setBlockUnknownCallers(event.enabled);
    add(const RestrictedCallsEvent.load());
  }

  Future<void> _onClearLogs(
    ClearRejectedCallLogs event,
    Emitter<RestrictedCallsState> emit,
  ) async {
    await repository.clearRejectedCalls();
    add(const RestrictedCallsEvent.load());
  }

  Future<void> _onSetRejectAll(
    SetRejectAllCalls event,
    Emitter<RestrictedCallsState> emit,
  ) async {
    await repository.setRejectAllCalls(event.enabled);
    add(const RestrictedCallsEvent.load());
  }

  Future<void> _onSetAllowOnlySelected(
    SetAllowOnlySelected event,
    Emitter<RestrictedCallsState> emit,
  ) async {
    await repository.setAllowOnlySelected(event.enabled);
    add(const RestrictedCallsEvent.load());
  }

  Future<void> _onAddAllowed(
    AddAllowedContacts event,
    Emitter<RestrictedCallsState> emit,
  ) async {
    await repository.addAllowedContacts(event.contacts);
    add(const RestrictedCallsEvent.load());
  }

  Future<void> _onRemoveAllowed(
    RemoveAllowedContact event,
    Emitter<RestrictedCallsState> emit,
  ) async {
    await repository.removeAllowedContact(event.phoneNumber);
    add(const RestrictedCallsEvent.load());
  }
}
