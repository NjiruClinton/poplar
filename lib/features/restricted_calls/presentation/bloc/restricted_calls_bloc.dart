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

      emit(
        RestrictedCallsState.loaded(
          contacts: contacts,
          rejectedCalls: rejectedCalls,
          blockUnknownCallers: blockUnknownCallers,
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
}
