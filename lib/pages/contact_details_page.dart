import 'package:flutter/material.dart';
import '../model/contact.dart';

class ContactDetailPage extends StatefulWidget {
  final Contact contact;
  final Function(Contact) onUpdate;
  final Function(int) onDelete;

  ContactDetailPage({
    required this.contact,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _ContactDetailPageState createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late List<String> _phones;
  late String _email;
  late bool _isFavorite;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _name = widget.contact.name;
    _phones = List.from(widget.contact.phones);
    _email = widget.contact.email;
    _isFavorite = widget.contact.isFavorite;
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset values if cancelled
        _name = widget.contact.name;
        _phones = List.from(widget.contact.phones);
        _email = widget.contact.email;
        _isFavorite = widget.contact.isFavorite;
      }
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Filter out empty phone numbers
      final validPhones = _phones.where((phone) => phone.trim().isNotEmpty).toList();

      if (validPhones.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add at least one phone number')),
        );
        return;
      }

      final updatedContact = widget.contact.copyWith(
        name: _name,
        phones: validPhones,
        email: _email,
        isFavorite: _isFavorite,
      );

      widget.onUpdate(updatedContact);
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact updated successfully')),
      );
    }
  }

  void _addPhoneField() {
    setState(() {
      _phones.add('');
    });
  }

  void _removePhoneField(int index) {
    setState(() {
      if (_phones.length > 1) {
        _phones.removeAt(index);
      }
    });
  }

  void _deleteContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${widget.contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(widget.contact.id!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Contact' : 'Contact Details'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveChanges,
            )
          else
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal,
                      child: Text(
                        _name[0].toUpperCase(),
                        style: TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_isEditing)
                      TextFormField(
                        initialValue: _name,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        onSaved: (v) => _name = v!,
                        validator: (v) => v!.isEmpty ? 'Enter name' : null,
                      )
                    else
                      Text(
                        _name,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    SizedBox(height: 8),
                    if (_isEditing)
                      CheckboxListTile(
                        title: Text('Favorite'),
                        value: _isFavorite,
                        onChanged: (bool? value) {
                          setState(() {
                            _isFavorite = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      )
                    else if (_isFavorite)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 4),
                          Text('Favorite'),
                        ],
                      ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Phone Numbers Section
              Text(
                'Phone Numbers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              if (_isEditing) ...[
                ...List.generate(_phones.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _phones[index],
                            decoration: InputDecoration(
                              labelText: 'Phone ${index + 1}',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            onSaved: (v) => _phones[index] = v ?? '',
                            validator: (v) {
                              if (index == 0 && (v == null || v.isEmpty)) {
                                return 'Enter at least one phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_phones.length > 1)
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removePhoneField(index),
                          ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: _addPhoneField,
                  icon: Icon(Icons.add),
                  label: Text('Add Phone Number'),
                ),
              ] else ...[
                ...widget.contact.phones.map((phone) => Card(
                  child: ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(phone),
                    trailing: IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () {
                        // Here you would implement calling functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling $phone...')),
                        );
                      },
                    ),
                  ),
                )).toList(),
              ],

              SizedBox(height: 24),

              // Email Section
              Text(
                'Email',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              if (_isEditing)
                TextFormField(
                  initialValue: _email,
                  decoration: InputDecoration(
                    labelText: 'Email (Optional)',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (v) => _email = v ?? '',
                )
              else if (_email.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.email),
                    title: Text(_email),
                    trailing: IconButton(
                      icon: Icon(Icons.mail),
                      onPressed: () {
                        // Here you would implement email functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening email to $_email...')),
                        );
                      },
                    ),
                  ),
                )
              else
                Card(
                  child: ListTile(
                    leading: Icon(Icons.email_outlined),
                    title: Text('No email provided'),
                    subtitle: Text('Tap edit to add email'),
                  ),
                ),

              SizedBox(height: 24),

              // Contact Info
              Text(
                'Contact Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              Card(
                child: ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Date Added'),
                  subtitle: Text(
                    '${widget.contact.dateAdded.day}/${widget.contact.dateAdded.month}/${widget.contact.dateAdded.year}',
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Action Buttons
              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        child: Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _toggleEdit,
                        child: Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _deleteContact,
                    icon: Icon(Icons.delete),
                    label: Text('Delete Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}