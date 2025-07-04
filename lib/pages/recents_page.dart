import 'package:flutter/material.dart';
import '../model/contact.dart';

class FavoritesContactsPage extends StatelessWidget {
  final List<Contact> contacts;

  FavoritesContactsPage({required this.contacts});

  @override
  Widget build(BuildContext context) {
    List<Contact> favorite = [...contacts];
    favorite.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    favorite = favorite.take(5).toList(); // Show latest 5

    return ListView.builder(
      itemCount: favorite.length,
      itemBuilder: (context, index) {
        final contact = favorite[index];
        return ListTile(
          title: Text(contact.name),
          subtitle: Text(contact.phone),
        );
      },
    );
  }
}