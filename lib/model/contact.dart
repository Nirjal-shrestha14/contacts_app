class Contact {
  final int? id;
  final String name;
  final List<String> phones;
  final String email;
  final bool isFavorite;
  final DateTime dateAdded;

  Contact({
    this.id,
    required this.name,
    required this.phones,
    this.email = '',
    this.isFavorite = false,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  // Convert Contact to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phones': phones.join(','), // Store as comma-separated string
      'email': email,
      'isFavorite': isFavorite ? 1 : 0,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
    };
  }

  // Create Contact from Map retrieved from database
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phones: map['phones'].toString().split(',').where((p) => p.isNotEmpty).toList(),
      email: map['email'] ?? '',
      isFavorite: map['isFavorite'] == 1,
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
    );
  }

  // Create a copy of contact with modified fields
  Contact copyWith({
    int? id,
    String? name,
    List<String>? phones,
    String? email,
    bool? isFavorite,
    DateTime? dateAdded,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phones: phones ?? this.phones,
      email: email ?? this.email,
      isFavorite: isFavorite ?? this.isFavorite,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, phones: $phones, email: $email, isFavorite: $isFavorite, dateAdded: $dateAdded}';
  }
}