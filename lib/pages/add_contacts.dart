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
  String _phone = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onAdd(Contact(name: _name, phone: _phone, addedAt: DateTime.now()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contact Added')));
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              onSaved: (value) => _name = value!,
              validator: (value) => value!.isEmpty ? 'Enter a name' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Phone'),
              onSaved: (value) => _phone = value!,
              validator: (value) => value!.isEmpty ? 'Enter a phone number' : null,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }
}