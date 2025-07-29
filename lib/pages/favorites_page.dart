import 'package:flutter/material.dart';
import '../model/contact.dart';
import 'contact_details_page.dart';

class FavoritesPage extends StatelessWidget {
  final List<Contact> contacts;
  final Function(Contact) onUpdate;
  final Function(int) onDelete;

  FavoritesPage({
    required this.contacts,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteContacts = contacts.where((c) => c.isFavorite).toList();

    if (favoriteContacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No favorite contacts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add contacts to favorites to see them here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: favoriteContacts.length,
      itemBuilder: (_, i) {
        final contact = favoriteContacts[i];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal,
              child: Text(
                contact.name[0].toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(contact.name),
            subtitle: Text(
              contact.email.isNotEmpty
                  ? '${contact.phones.first} • ${contact.email}'
                  : contact.phones.first,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Icons.star, color: Colors.amber),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailPage(
                    contact: contact,
                    onUpdate: onUpdate,
                    onDelete: onDelete,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}