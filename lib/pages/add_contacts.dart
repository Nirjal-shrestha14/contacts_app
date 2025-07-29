import 'package:flutter/material.dart';
import '../model/contact.dart';

class AddContactPage extends StatefulWidget {
  final Function(Contact) onAdd;
  AddContactPage({required this.onAdd});

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  List<String> _phones = [''];
  String _email = '';
  bool _isFavorite = false;

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

  void _submit() async {
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

      // Create contact and add to database
      await widget.onAdd(Contact(
        name: _name,
        phones: validPhones,
        email: _email,
        isFavorite: _isFavorite,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact Added Successfully')),
      );

      // Reset form
      _formKey.currentState!.reset();
      setState(() {
        _name = '';
        _phones = [''];
        _email = '';
        _isFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => _name = v!,
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              SizedBox(height: 16),

              // Phone numbers section
              Text('Phone Numbers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              ...List.generate(_phones.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Phone ${index + 1}',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
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
                style: TextButton.styleFrom(foregroundColor: Colors.teal),
              ),

              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email (Optional)',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => _email = v ?? '',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v != null && v.isNotEmpty && !v.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Add to Favorites'),
                value: _isFavorite,
                onChanged: (bool? value) {
                  setState(() {
                    _isFavorite = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.teal,
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Add Contact'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}