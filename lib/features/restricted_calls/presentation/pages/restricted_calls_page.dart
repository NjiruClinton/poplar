import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/platform/contacts_platform.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../domain/entities/rejected_call.dart';
import '../../domain/entities/restricted_contact.dart';
import '../bloc/restricted_calls_bloc.dart';
import '../bloc/restricted_calls_event.dart';
import '../bloc/restricted_calls_state.dart';
import 'contact_picker_page.dart';

class RestrictedCallsPage extends StatefulWidget {
  const RestrictedCallsPage({super.key});
  @override
  State<RestrictedCallsPage> createState() => _RestrictedCallsPageState();
}

class _RestrictedCallsPageState extends State<RestrictedCallsPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(['Poplar', 'Blocked callers', 'Call activity'][_index]),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => context.read<RestrictedCallsBloc>().add(
            const RestrictedCallsEvent.load(),
          ),
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 8),
      ],
    ),
    floatingActionButton: _index == 1
        ? FloatingActionButton.extended(
            onPressed: _showAddOptions,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add'),
          )
        : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: Icon(Icons.block_outlined),
          selectedIcon: Icon(Icons.block),
          label: 'Blocked',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Activity',
        ),
      ],
    ),
    body: BlocBuilder<RestrictedCallsBloc, RestrictedCallsState>(
      builder: (context, state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => _ErrorView(message: message),
        loaded: (contacts, rejectedCalls, blockUnknownCallers, isUpdating) =>
            RefreshIndicator(
              onRefresh: () async {
                context.read<RestrictedCallsBloc>().add(
                  const RestrictedCallsEvent.load(),
                );
                await context.read<RestrictedCallsBloc>().stream.firstWhere(
                  (s) => s is RestrictedCallsLoaded,
                );
              },
              child: IndexedStack(
                index: _index,
                children: [
                  _Overview(
                    contacts: contacts,
                    calls: rejectedCalls,
                    blockUnknown: blockUnknownCallers,
                    onToggleUnknown: (enabled) => context
                        .read<RestrictedCallsBloc>()
                        .add(RestrictedCallsEvent.setBlockUnknown(enabled)),
                    onManage: () => setState(() => _index = 1),
                  ),
                  _BlockedList(contacts: contacts, onAdd: _showAddOptions),
                  _ActivityList(calls: rejectedCalls),
                ],
              ),
            ),
      ),
    ),
  );

  void _showAddOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Add to block list',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.contacts_outlined),
                ),
                title: const Text('Choose contacts'),
                subtitle: const Text('Search and select multiple people'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openContacts();
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.dialpad_outlined),
                ),
                title: const Text('Enter a number'),
                subtitle: const Text('Block a number not saved in contacts'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showManualNumber();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openContacts() => Navigator.push(
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

  Future<void> _showManualNumber() async {
    final controller = TextEditingController();
    final number = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block a number'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            hintText: 'e.g. 0712 345 678',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (number == null || number.trim().isEmpty || !mounted) return;
    final normalized = PhoneUtils.normalizeKenyanNumber(number);
    context.read<RestrictedCallsBloc>().add(
      RestrictedCallsEvent.add(
        RestrictedContact(phoneNumber: normalized, createdAt: DateTime.now()),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.contacts,
    required this.calls,
    required this.blockUnknown,
    required this.onToggleUnknown,
    required this.onManage,
  });
  final List<RestrictedContact> contacts;
  final List<RejectedCall> calls;
  final bool blockUnknown;
  final ValueChanged<bool> onToggleUnknown;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final recent = calls
        .where((c) => DateTime.now().difference(c.timestamp).inDays < 7)
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Card(
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  child: const Icon(Icons.shield, size: 30),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Protection is active',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${contacts.length} blocked • $recent stopped this week',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: 'Blocked callers',
                value: '${contacts.length}',
                icon: Icons.person_off_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stat(
                label: 'Rejected calls',
                value: '${calls.length}',
                icon: Icons.call_missed_outgoing,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Smart protection',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: SwitchListTile(
            value: blockUnknown,
            onChanged: onToggleUnknown,
            secondary: const Icon(Icons.contact_phone_outlined),
            title: const Text('Block callers outside contacts'),
            subtitle: const Text(
              'Reject incoming numbers that are not saved on this device.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Manage block list'),
            subtitle: const Text('Add contacts or individual phone numbers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onManage,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 14),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

class _BlockedList extends StatelessWidget {
  const _BlockedList({required this.contacts, required this.onAdd});
  final List<RestrictedContact> contacts;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty)
      return _Empty(
        icon: Icons.person_add_alt,
        title: 'Your block list is empty',
        message: 'Add contacts or phone numbers you do not want to hear from.',
        action: onAdd,
      );
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
      itemCount: contacts.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final name = contact.name?.trim();
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              (name?.isNotEmpty ?? false) ? name![0].toUpperCase() : '#',
            ),
          ),
          title: Text((name?.isNotEmpty ?? false) ? name! : 'Unknown number'),
          subtitle: Text(contact.phoneNumber),
          trailing: IconButton(
            tooltip: 'Unblock',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => context.read<RestrictedCallsBloc>().add(
              RestrictedCallsEvent.remove(contact.phoneNumber),
            ),
          ),
        );
      },
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.calls});
  final List<RejectedCall> calls;
  @override
  Widget build(BuildContext context) {
    if (calls.isEmpty)
      return const _Empty(
        icon: Icons.check_circle_outline,
        title: 'No rejected calls',
        message: 'Calls stopped by Poplar will appear here.',
      );
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
      itemCount: calls.length + 1,
      itemBuilder: (context, index) {
        if (index == 0)
          return Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.read<RestrictedCallsBloc>().add(
                const RestrictedCallsEvent.clearLogs(),
              ),
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Clear history'),
            ),
          );
        final call = calls[index - 1];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            child: Icon(
              Icons.call_missed,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          title: Text(call.contactName ?? call.phoneNumber),
          subtitle: Text(
            call.contactName == null
                ? 'Rejected'
                : '${call.phoneNumber} • Rejected',
          ),
          trailing: Text(
            _relative(call.timestamp),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }

  String _relative(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) return 'Now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => ListView(
    children: [
      SizedBox(height: MediaQuery.sizeOf(context).height * .18),
      Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
      const SizedBox(height: 16),
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(message, textAlign: TextAlign.center),
      ),
      if (action != null)
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: FilledButton.icon(
              onPressed: action,
              icon: const Icon(Icons.add),
              label: const Text('Add caller'),
            ),
          ),
        ),
    ],
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          const Text('Something went wrong'),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => context.read<RestrictedCallsBloc>().add(
              const RestrictedCallsEvent.load(),
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}
