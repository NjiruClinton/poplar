import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/restricted_contact.dart';
import '../bloc/restricted_calls_bloc.dart';
import '../bloc/restricted_calls_event.dart';
import '../bloc/restricted_calls_state.dart';

class RestrictedCallsPage extends StatelessWidget {
  const RestrictedCallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restricted Calls')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final RestrictedContact contact = RestrictedContact(
            phoneNumber: '+254712345678',
            name: 'Test Number',
            createdAt: DateTime.now(),
          );

          context.read<RestrictedCallsBloc>().add(
            RestrictedCallsEvent.add(contact),
          );
        },
        child: const Icon(Icons.add),
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
