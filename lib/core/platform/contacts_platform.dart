import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ContactsPlatform {
  Future<bool> ensurePermission() async {
    final PermissionStatus permission = await FlutterContacts.permissions
        .request(PermissionType.read);

    return permission == PermissionStatus.granted;
  }

  Future<List<Contact>> getContacts({int limit = 60, String query = ''}) async {
    if (!await ensurePermission()) {
      return [];
    }

    return FlutterContacts.getAll(
      properties: {ContactProperty.name, ContactProperty.phone},
      filter: query.trim().isEmpty ? null : ContactFilter.name(query.trim()),
      limit: limit,
    );
  }
}
