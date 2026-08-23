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
    on<RemoveRestrictedContact>(_onRemove);
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

      emit(
        RestrictedCallsState.loaded(
          contacts: contacts,
          rejectedCalls: rejectedCalls,
        ),
      );
    } catch (error) {
      emit(RestrictedCallsState.error(error.toString()));
    }
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
}
