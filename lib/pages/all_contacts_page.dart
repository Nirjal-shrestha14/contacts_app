import 'package:flutter/material.dart';
import '../model/contact.dart';

class AllContactsPage extends StatelessWidget {
  final List<Contact> contacts;

  AllContactsPage({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          title: Text(contact.name),
          subtitle: Text(contact.phone),
        );
      },
    );
  }
}