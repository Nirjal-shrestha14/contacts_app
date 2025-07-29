import 'package:flutter/material.dart';
import '../model/contact.dart';
import 'contact_details_page.dart';

class AllContactsPage extends StatefulWidget {
  final List<Contact> contacts;
  final Function(Contact) onUpdate;
  final Function(int) onDelete;

  AllContactsPage({
    required this.contacts,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _AllContactsPageState createState() => _AllContactsPageState();
}

class _AllContactsPageState extends State<AllContactsPage> {
  List<Contact> _filteredContacts = [];
  String _searchQuery = '';
  String _sortBy = 'name'; // 'name' or 'date'
  bool _ascending = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
    _sortContacts();
  }

  @override
  void didUpdateWidget(AllContactsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contacts != widget.contacts) {
      _filteredContacts = widget.contacts;
      _applyFilters();
    }
  }

  void _sortContacts() {
    setState(() {
      _filteredContacts.sort((a, b) {
        int comparison;
        if (_sortBy == 'name') {
          comparison = a.name.compareTo(b.name);
        } else {
          comparison = a.dateAdded.compareTo(b.dateAdded);
        }
        return _ascending ? comparison : -comparison;
      });
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredContacts = widget.contacts.where((contact) {
        return contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            contact.phones.any((phone) => phone.contains(_searchQuery)) ||
            contact.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      _sortContacts();
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sort Contacts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('Name'),
              value: 'name',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
              },
            ),
            RadioListTile<String>(
              title: Text('Date Added'),
              value: 'date',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Order: '),
                Switch(
                  value: _ascending,
                  onChanged: (value) {
                    setState(() => _ascending = value);
                  },
                ),
                Text(_ascending ? 'Ascending' : 'Descending'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _sortContacts();
              Navigator.pop(context);
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search contacts...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilters();
                  },
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.sort),
                onPressed: _showSortDialog,
                tooltip: 'Sort contacts',
              ),
            ],
          ),
        ),

        // Contacts List
        Expanded(
          child: _filteredContacts.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.contacts, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'No contacts yet' : 'No contacts found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                if (_searchQuery.isNotEmpty)
                  Text(
                    'Try a different search term',
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _filteredContacts.length,
            itemBuilder: (_, i) {
              final contact = _filteredContacts[i];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Dismissible(
                  key: Key(contact.id.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => widget.onDelete(contact.id!),
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
                    trailing: contact.isFavorite
                        ? Icon(Icons.star, color: Colors.amber)
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactDetailPage(
                            contact: contact,
                            onUpdate: widget.onUpdate,
                            onDelete: widget.onDelete,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}