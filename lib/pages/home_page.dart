import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../model/contact.dart';
import 'all_contacts_page.dart';
import 'favorites_page.dart';
import 'add_contacts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final dbHelper = DatabaseHelper.instance;
  late Future<List<Contact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    setState(() {
      _contactsFuture = dbHelper.getAllContacts();
    });
  }

  void _addContact(Contact contact) async {
    try {
      await dbHelper.insert(contact);
      _loadContacts();
      // Navigate to All Contacts tab after adding
      setState(() {
        _selectedIndex = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding contact: $e')),
      );
    }
  }

  void _updateContact(Contact contact) async {
    try {
      await dbHelper.update(contact);
      _loadContacts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating contact: $e')),
      );
    }
  }

  void _deleteContact(int id) async {
    try {
      await dbHelper.delete(id);
      _loadContacts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting contact: $e')),
      );
    }
  }

  List<Widget> _buildPages(List<Contact> contacts) => [
    FavoritesPage(
      contacts: contacts,
      onUpdate: _updateContact,
      onDelete: _deleteContact,
    ),
    AllContactsPage(
      contacts: contacts,
      onUpdate: _updateContact,
      onDelete: _deleteContact,
    ),
    AddContactPage(onAdd: _addContact),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Contact>>(
      future: _contactsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Contacts App'),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }

        final contacts = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text('Contacts App'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _loadContacts,
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: _buildPages(contacts)[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.teal,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'All Contacts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add Contact',
              ),
            ],
          ),
        );
      },
    );
  }
}