import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../../core/platform/contacts_platform.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../domain/entities/restricted_contact.dart';
import '../bloc/restricted_calls_bloc.dart';
import '../bloc/restricted_calls_event.dart';

class ContactPickerPage extends StatefulWidget {
  const ContactPickerPage({super.key});

  @override
  State<ContactPickerPage> createState() => _ContactPickerPageState();
}

class _ContactPickerPageState extends State<ContactPickerPage> {
  List<Contact> contacts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final ContactsPlatform contactsPlatform = context.read<ContactsPlatform>();

    final List<Contact> result = await contactsPlatform.getContacts();

    if (!mounted) {
      return;
    }

    setState(() {
      contacts = result;
      loading = false;
    });
  }

  void _selectContact(Contact contact) {
    final List<Phone> phones = contact.phones ?? [];

    if (phones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This contact has no phone number')),
      );

      return;
    }

    if (phones.length == 1) {
      _addContact(contact, phones.first.number);

      return;
    }

    _showPhoneNumbers(contact, phones);
  }

  void _showPhoneNumbers(Contact contact, List<Phone> phones) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(contact.displayName ?? 'Unknown'),
                subtitle: const Text('Select a phone number'),
              ),
              ...phones.map((phone) {
                return ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(phone.number),
                  onTap: () {
                    Navigator.pop(context);

                    _addContact(contact, phone.number);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _addContact(Contact contact, String phoneNumber) {
    final String normalizedNumber = PhoneUtils.normalizeKenyanNumber(
      phoneNumber,
    );

    final String? contactName = contact.displayName;

    final RestrictedContact restrictedContact = RestrictedContact(
      phoneNumber: normalizedNumber,
      name: contactName,
      createdAt: DateTime.now(),
    );

    context.read<RestrictedCallsBloc>().add(
      RestrictedCallsEvent.add(restrictedContact),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Contact')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
          ? const Center(child: Text('No contacts found'))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final Contact contact = contacts[index];

                final String name = contact.displayName ?? 'Unknown';

                final List<Phone> phones = contact.phones ?? [];

                final String subtitle = phones.isEmpty
                    ? 'No phone number'
                    : phones.first.number;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
                  ),
                  title: Text(name),
                  subtitle: Text(subtitle),
                  onTap: () {
                    _selectContact(contact);
                  },
                );
              },
            ),
    );
  }
}
