import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/platform/contacts_platform.dart';
import '../../domain/entities/restricted_contact.dart';
import '../bloc/restricted_calls_bloc.dart';
import '../bloc/restricted_calls_event.dart';
import '../bloc/restricted_calls_state.dart';
import 'contact_picker_page.dart';

class RestrictedCallsPage extends StatelessWidget {
  const RestrictedCallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restricted Calls')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepositoryProvider.value(
                value: context.read<ContactsPlatform>(),
                child: BlocProvider.value(
                  value: context.read<RestrictedCallsBloc>(),
                  child: const ContactPickerPage(),
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
      body: BlocBuilder<RestrictedCallsBloc, RestrictedCallsState>(
        builder: (context, state) {
          return state.when(
            initial: () {
              return const SizedBox.shrink();
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
            error: (message) {
              return Center(child: Text(message));
            },
            loaded: (contacts, rejectedCalls) {
              if (contacts.isEmpty) {
                return const Center(child: Text('No restricted numbers'));
              }

              return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final RestrictedContact contact = contacts[index];

                  return ListTile(
                    title: Text(contact.name ?? 'Unknown'),
                    subtitle: Text(contact.phoneNumber),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context.read<RestrictedCallsBloc>().add(
                          RestrictedCallsEvent.remove(contact.phoneNumber),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
