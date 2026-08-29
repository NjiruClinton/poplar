import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../../core/platform/contacts_platform.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../domain/entities/restricted_contact.dart';
import '../bloc/restricted_calls_bloc.dart';
import '../bloc/restricted_calls_event.dart';

enum ContactPickerPurpose { block, allow }

class ContactPickerPage extends StatefulWidget {
  const ContactPickerPage({
    super.key,
    this.purpose = ContactPickerPurpose.block,
  });
  final ContactPickerPurpose purpose;
  @override
  State<ContactPickerPage> createState() => _ContactPickerPageState();
}

class _ContactPickerPageState extends State<ContactPickerPage> {
  static const _pageSize = 60;
  final _selected = <String, RestrictedContact>{};
  final _searchController = TextEditingController();
  List<Contact> _contacts = const [];
  Timer? _debounce;
  int _limit = _pageSize;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      _limit = _pageSize;
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      _limit += _pageSize;
      setState(() => _loadingMore = true);
    }
    try {
      final result = await context.read<ContactsPlatform>().getContacts(
        limit: _limit,
        query: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _contacts = result;
        _hasMore = result.length >= _limit;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Contacts could not be loaded. Check contact permission.';
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _search(String _) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _load(reset: true),
    );
  }

  Future<void> _toggle(Contact contact) async {
    final phones = contact.phones ?? const <Phone>[];
    if (phones.isEmpty) return;
    Phone? chosen;
    if (phones.length == 1) {
      chosen = phones.first;
    } else {
      chosen = await showModalBottomSheet<Phone>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(contact.displayName ?? 'Choose a number'),
                subtitle: Text(
                  widget.purpose == ContactPickerPurpose.block
                      ? 'Which number should be blocked?'
                      : 'Which number should be allowed?',
                ),
              ),
              for (final phone in phones)
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(phone.number),
                  onTap: () => Navigator.pop(context, phone),
                ),
            ],
          ),
        ),
      );
    }
    if (chosen == null || !mounted) return;
    final number = PhoneUtils.normalizeKenyanNumber(chosen.number);
    setState(() {
      if (_selected.containsKey(number)) {
        _selected.remove(number);
      } else {
        _selected[number] = RestrictedContact(
          phoneNumber: number,
          name: contact.displayName,
          createdAt: DateTime.now(),
        );
      }
    });
  }

  void _save() {
    context.read<RestrictedCallsBloc>().add(
      widget.purpose == ContactPickerPurpose.block
          ? RestrictedCallsEvent.addMany(
              _selected.values.toList(growable: false),
            )
          : RestrictedCallsEvent.addAllowed(
              _selected.values.toList(growable: false),
            ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Choose contacts'),
      actions: [
        if (_selected.isNotEmpty)
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text('Add ${_selected.length}'),
          ),
        const SizedBox(width: 8),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SearchBar(
            controller: _searchController,
            onChanged: _search,
            leading: const Icon(Icons.search),
            hintText: 'Search contacts',
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _load(reset: true);
                  },
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
        ),
        Expanded(child: _content()),
      ],
    ),
  );

  Widget _content() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null)
      return _Message(message: _error!, onRetry: () => _load(reset: true));
    if (_contacts.isEmpty)
      return const _Message(message: 'No matching contacts');
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 500) _load(reset: false);
        return false;
      },
      child: ListView.builder(
        itemCount: _contacts.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _contacts.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final contact = _contacts[index];
          final phones = contact.phones ?? const <Phone>[];
          final selected = phones.any(
            (p) => _selected.containsKey(
              PhoneUtils.normalizeKenyanNumber(p.number),
            ),
          );
          final name = contact.displayName?.trim();
          final label = (name?.isNotEmpty ?? false) ? name! : 'Unnamed contact';
          return CheckboxListTile(
            value: selected,
            onChanged: phones.isEmpty ? null : (_) => _toggle(contact),
            secondary: CircleAvatar(child: Text(label[0].toUpperCase())),
            title: Text(label),
            subtitle: Text(
              phones.isEmpty ? 'No phone number' : phones.first.number,
            ),
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ],
      ),
    ),
  );
}
