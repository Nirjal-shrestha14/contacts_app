import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/contact.dart';

class DatabaseHelper {
  static const _databaseName = "Contacts.db";
  static const _databaseVersion = 2; // Increased version for schema changes
  static const table = 'contacts';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnPhones = 'phones';
  static const columnEmail = 'email';
  static const columnIsFavorite = 'isFavorite';
  static const columnDateAdded = 'dateAdded';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnPhones TEXT NOT NULL,
        $columnEmail TEXT NOT NULL DEFAULT '',
        $columnIsFavorite INTEGER NOT NULL DEFAULT 0,
        $columnDateAdded INTEGER NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for existing databases
      await db.execute('ALTER TABLE $table ADD COLUMN $columnIsFavorite INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE $table ADD COLUMN $columnDateAdded INTEGER NOT NULL DEFAULT ${DateTime.now().millisecondsSinceEpoch}');
      // Rename phone column to phones and update existing data
      await db.execute('ALTER TABLE $table RENAME COLUMN phone TO $columnPhones');
    }
  }

  Future<int> insert(Contact contact) async {
    Database db = await instance.database;
    return await db.insert(table, contact.toMap());
  }

  Future<List<Contact>> getAllContacts() async {
    Database db = await instance.database;
    final maps = await db.query(table, orderBy: "$columnName ASC");
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  Future<List<Contact>> getFavoriteContacts() async {
    Database db = await instance.database;
    final maps = await db.query(
      table,
      where: '$columnIsFavorite = ?',
      whereArgs: [1],
      orderBy: "$columnName ASC",
    );
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  Future<List<Contact>> searchContacts(String query) async {
    Database db = await instance.database;
    final maps = await db.query(
      table,
      where: '$columnName LIKE ? OR $columnPhones LIKE ? OR $columnEmail LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: "$columnName ASC",
    );
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  Future<List<Contact>> getContactsSorted(String sortBy, bool ascending) async {
    Database db = await instance.database;
    String orderBy;
    switch (sortBy) {
      case 'name':
        orderBy = "$columnName ${ascending ? 'ASC' : 'DESC'}";
        break;
      case 'date':
        orderBy = "$columnDateAdded ${ascending ? 'ASC' : 'DESC'}";
        break;
      default:
        orderBy = "$columnName ASC";
    }

    final maps = await db.query(table, orderBy: orderBy);
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  Future<int> update(Contact contact) async {
    Database db = await instance.database;
    return await db.update(
      table,
      contact.toMap(),
      where: '$columnId = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}