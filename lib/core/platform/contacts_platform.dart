import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ContactsPlatform {
  Future<List<Contact>> getContacts() async {
    final PermissionStatus permission = await FlutterContacts.permissions
        .request(PermissionType.read);

    if (permission != PermissionStatus.granted) {
      return [];
    }

    return FlutterContacts.getAll(
      properties: {ContactProperty.name, ContactProperty.phone},
    );
  }
}
