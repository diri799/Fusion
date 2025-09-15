import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static DatabaseService get instance => _instance;

  Database? _database;
  Map<String, List<Map<String, dynamic>>> _webData = {};

  Future<Database> get database async {
    print('DatabaseService.database called - kIsWeb: $kIsWeb');
    if (kIsWeb) {
      // For web, return a simple web database
      print('Using web database for web platform');
      return _getWebDatabase();
    }
    
    print('Using real database for mobile/desktop platform');
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      // Try to get documents directory for mobile/desktop
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'fusion_fiesta.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('Error initializing database with path_provider: $e');
      // Fallback to web database
      print('Using web database as fallback');
      return _getWebDatabase();
    }
  }

  Database _getWebDatabase() {
    print('_getWebDatabase called');
    // Initialize web data if not already done
    if (_webData.isEmpty) {
      _webData['events'] = [];
      _webData['users'] = [];
      _webData['registrations'] = [];
      print('Initialized web data tables');
    }
    
    print('Returning WebDatabase instance');
    return WebDatabase(_webData);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        user_id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        first_name TEXT,
        last_name TEXT,
        phone TEXT,
        profile_image_url TEXT,
        bio TEXT,
        is_verified INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Create events table
    await db.execute('''
      CREATE TABLE events (
        event_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        status TEXT NOT NULL,
        organizer_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        registration_deadline TEXT,
        venue TEXT,
        max_participants INTEGER,
        registration_fee REAL DEFAULT 0,
        requirements TEXT,
        banner_image_url TEXT,
        event_agenda TEXT,
        is_featured INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (organizer_id) REFERENCES users (user_id)
      )
    ''');

    // Create registrations table
    await db.execute('''
      CREATE TABLE registrations (
        registration_id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        registration_date TEXT NOT NULL,
        status TEXT NOT NULL,
        payment_status TEXT,
        payment_reference TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (event_id) REFERENCES events (event_id),
        FOREIGN KEY (user_id) REFERENCES users (user_id),
        UNIQUE(event_id, user_id)
      )
    ''');

  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // User operations
  Future<int> createUser(Map<String, dynamic> userData) async {
    final db = await database;
    return await db.insert('users', userData);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUser(String userId, Map<String, dynamic> userData) async {
    final db = await database;
    return await db.update(
      'users',
      userData,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUser(String userId) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Event operations
  Future<int> createEvent(Map<String, dynamic> eventData) async {
    if (kIsWeb) {
      // For web, use simple in-memory storage
      if (!_webData.containsKey('events')) {
        _webData['events'] = [];
      }
      _webData['events']!.add(Map<String, dynamic>.from(eventData));
      print('Web createEvent: ${eventData['title']}');
      return 1;
    }
    
    final db = await database;
    return await db.insert('events', eventData);
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    if (kIsWeb) {
      // For web, return events from in-memory storage
      return _webData['events'] ?? [];
    }
    
    final db = await database;
    return await db.query('events', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getEventById(String eventId) async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getEventsByOrganizer(String organizerId) async {
    final db = await database;
    return await db.query(
      'events',
      where: 'organizer_id = ?',
      whereArgs: [organizerId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    final db = await database;
    return await db.update(
      'events',
      eventData,
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }

  Future<int> deleteEvent(String eventId) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }

  // Registration operations
  Future<int> createRegistration(Map<String, dynamic> registrationData) async {
    final db = await database;
    return await db.insert('registrations', registrationData);
  }

  Future<List<Map<String, dynamic>>> getRegistrationsByEvent(String eventId) async {
    final db = await database;
    return await db.query(
      'registrations',
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'registration_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getRegistrationsByUser(String userId) async {
    final db = await database;
    return await db.query(
      'registrations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'registration_date DESC',
    );
  }

  Future<Map<String, dynamic>?> getRegistration(String eventId, String userId) async {
    final db = await database;
    final results = await db.query(
      'registrations',
      where: 'event_id = ? AND user_id = ?',
      whereArgs: [eventId, userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateRegistration(String registrationId, Map<String, dynamic> registrationData) async {
    final db = await database;
    return await db.update(
      'registrations',
      registrationData,
      where: 'registration_id = ?',
      whereArgs: [registrationId],
    );
  }

  Future<int> deleteRegistration(String registrationId) async {
    final db = await database;
    return await db.delete(
      'registrations',
      where: 'registration_id = ?',
      whereArgs: [registrationId],
    );
  }


  // Utility methods
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Initialize database (call this in main.dart)
  Future<void> initDatabase() async {
    await database;
  }

  // Raw query method for complex queries
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // Raw update method for complex updates
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  // Generic database operations that other services use
  Future<List<Map<String, dynamic>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<dynamic>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async {
    if (kIsWeb) {
      // For web, return data from in-memory storage
      return _webData[table] ?? [];
    }
    
    final db = await database;
    return await db.query(table, distinct: distinct, columns: columns, where: where, whereArgs: whereArgs, groupBy: groupBy, having: having, orderBy: orderBy, limit: limit, offset: offset);
  }

  Future<int> insert(String table, Map<String, dynamic> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    if (kIsWeb) {
      // For web, use simple in-memory storage
      if (!_webData.containsKey(table)) {
        _webData[table] = [];
      }
      _webData[table]!.add(Map<String, dynamic>.from(values));
      print('Web insert into $table: ${values['title'] ?? values['name'] ?? 'unknown'}');
      return 1;
    }
    
    final db = await database;
    return await db.insert(table, values, nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm);
  }

  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    if (kIsWeb) {
      // For web, simple update implementation
      print('Web update in $table: ${values['title'] ?? values['name'] ?? 'unknown'}');
      return 1;
    }
    
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs, conflictAlgorithm: conflictAlgorithm);
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    if (kIsWeb) {
      // For web, simple delete implementation
      print('Web delete from $table');
      return 1;
    }
    
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}

// Simple Web Database for web platform - implements only the methods we need
class WebDatabase implements Database {
  final Map<String, List<Map<String, dynamic>>> _data;

  WebDatabase(this._data) {
    print('WebDatabase constructor called with ${_data.length} tables');
  }

  @override
  String get path => ':memory:';

  @override
  int get version => 1;

  @override
  bool get isOpen => true;

  @override
  Database get database => this;

  @override
  Future<void> close() async {
    // Web implementation - no-op
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    print('WebDatabase.insert called for table: $table');
    if (!_data.containsKey(table)) {
      _data[table] = [];
      print('Created new table: $table');
    }
    
    // Add a unique ID if not provided
    if (!values.containsKey('id') && !values.containsKey('${table}_id')) {
      values['${table}_id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    _data[table]!.add(Map<String, dynamic>.from(values));
    print('Web insert into $table: $values');
    print('Table $table now has ${_data[table]!.length} records');
    return 1; // Return row ID
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<dynamic>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async {
    if (!_data.containsKey(table)) {
      return [];
    }
    
    List<Map<String, dynamic>> results = List.from(_data[table]!);
    
    // Simple where clause handling
    if (where != null && whereArgs != null) {
      results = results.where((row) {
        // Basic where clause matching
        for (int i = 0; i < whereArgs.length; i++) {
          final placeholder = '?';
          if (where.contains(placeholder)) {
            final column = where.split('=')[0].trim();
            if (row[column] != whereArgs[i]) {
              return false;
            }
          }
        }
        return true;
      }).toList();
    }
    
    print('Web query from $table: ${results.length} results');
    return results;
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    if (!_data.containsKey(table)) {
      return 0;
    }
    
    int updated = 0;
    for (int i = 0; i < _data[table]!.length; i++) {
      final row = _data[table]![i];
      bool matches = true;
      
      if (where != null && whereArgs != null) {
        for (int j = 0; j < whereArgs.length; j++) {
          final placeholder = '?';
          if (where.contains(placeholder)) {
            final column = where.split('=')[0].trim();
            if (row[column] != whereArgs[j]) {
              matches = false;
              break;
            }
          }
        }
      }
      
      if (matches) {
        _data[table]![i] = {...row, ...values};
        updated++;
      }
    }
    
    print('Web update in $table: $updated rows updated');
    return updated;
  }

  @override
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    if (!_data.containsKey(table)) {
      return 0;
    }
    
    int deleted = 0;
    _data[table]!.removeWhere((row) {
      bool matches = true;
      
      if (where != null && whereArgs != null) {
        for (int j = 0; j < whereArgs.length; j++) {
          final placeholder = '?';
          if (where.contains(placeholder)) {
            final column = where.split('=')[0].trim();
            if (row[column] != whereArgs[j]) {
              matches = false;
              break;
            }
          }
        }
      }
      
      if (matches) {
        deleted++;
        return true; // Remove this row
      }
      return false; // Keep this row
    });
    
    print('Web delete from $table: $deleted rows deleted');
    return deleted;
  }

  @override
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    print('Web execute: $sql');
    // Web implementation - just log the SQL
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action, {bool? exclusive}) async {
    // Web transaction - just execute the action
    return await action(WebTransaction(this));
  }

  // Other required methods with web implementations
  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    print('Web rawQuery: $sql');
    return [];
  }

  @override
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    print('Web rawInsert: $sql');
    return 1;
  }

  @override
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    print('Web rawUpdate: $sql');
    return 1;
  }

  @override
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    print('Web rawDelete: $sql');
    return 1;
  }

  @override
  Future<void> executeBatch(List<dynamic> operations) async {
    print('Web executeBatch: ${operations.length} operations');
  }

  @override
  Batch batch() {
    return WebBatch();
  }

  // Minimal implementations for other required methods - just return default values
  @override
  Future<bool> isDatabaseClosed() async => false;
  @override
  Future<void> setVersion(int version) async {}
  @override
  Future<int> getVersion() async => 1;
  @override
  Future<void> setMaximumSize(int sizeInBytes) async {}
  @override
  Future<int> getMaximumSize() async => 1000000;
  @override
  Future<int> getPageSize() async => 4096;
  @override
  Future<void> setPageSize(int pageSize) async {}
  @override
  Future<void> enableWriteAheadLogging() async {}
  @override
  Future<bool> isWriteAheadLoggingEnabled() async => false;
  @override
  Future<void> disableWriteAheadLogging() async {}
  @override
  Future<void> compact() async {}
  @override
  Future<void> vacuum() async {}
  @override
  Future<void> cancelTransaction() async {}
  @override
  Future<void> yieldIfContendedSafely() async {}
  @override
  Future<void> invalidate() async {}
  @override
  Future<void> reinitialize() async {}
  @override
  Future<void> setForeignKeyConstraintsEnabled(bool enable) async {}
  @override
  Future<bool> isForeignKeyConstraintsEnabled() async => true;
  @override
  Future<void> setWalMode() async {}
  @override
  Future<void> setDeleteDatabaseOnClose() async {}
  @override
  Future<bool> isDeleteDatabaseOnClose() async => false;
  @override
  Future<void> setAutomaticVacuum(int mode) async {}
  @override
  Future<int> getAutomaticVacuum() async => 0;
  @override
  Future<void> setJournalMode(String mode) async {}
  @override
  Future<String> getJournalMode() async => 'delete';
  @override
  Future<void> setSynchronousMode(int mode) async {}
  @override
  Future<int> getSynchronousMode() async => 2;
  @override
  Future<void> setLockingMode(String mode) async {}
  @override
  Future<String> getLockingMode() async => 'normal';
  @override
  Future<void> setCacheSize(int size) async {}
  @override
  Future<int> getCacheSize() async => 2000;
  @override
  Future<void> setTempStore(int store) async {}
  @override
  Future<int> getTempStore() async => 0;
  @override
  Future<void> setUserVersion(int version) async {}
  @override
  Future<int> getUserVersion() async => 0;
  @override
  Future<void> setApplicationId(int id) async {}
  @override
  Future<int> getApplicationId() async => 0;
  @override
  Future<void> setLocale(String locale) async {}
  @override
  Future<String> getLocale() async => 'en_US';
  @override
  Future<void> setReadOnly() async {}
  @override
  Future<bool> isReadOnly() async => false;
  @override
  Future<void> setOpenParams(OpenDatabaseOptions options) async {}
  @override
  Future<OpenDatabaseOptions> getOpenParams() async => OpenDatabaseOptions();
  @override
  Future<void> setAttachAlias(String alias, String path) async {}
  @override
  Future<void> detachDatabase(String alias) async {}
  @override
  Future<List<String>> getAttachedDatabases() async => [];
  @override
  Future<void> setCustomFunction(String name, Function function) async {}
  @override
  Future<void> removeCustomFunction(String name) async {}
  @override
  Future<List<String>> getCustomFunctions() async => [];
  @override
  Future<void> setProgressHandler(Function? handler) async {}
  @override
  Future<void> setUpdateHandler(Function? handler) async {}
  @override
  Future<void> setCommitHandler(Function? handler) async {}
  @override
  Future<void> setRollbackHandler(Function? handler) async {}
  @override
  Future<void> setAuthorizerHandler(Function? handler) async {}
  @override
  Future<void> setTraceHandler(Function? handler) async {}
  @override
  Future<void> setProfileHandler(Function? handler) async {}
  @override
  Future<void> setBusyHandler(Function? handler) async {}
  @override
  Future<void> setBusyTimeout(Duration timeout) async {}
  @override
  Future<Duration> getBusyTimeout() async => Duration.zero;
  @override
  Future<T> readTransaction<T>(Future<T> Function(Transaction txn) action) async {
    return await action(WebTransaction(this));
  }
  @override
  Future<QueryCursor> queryCursor(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset, int? bufferSize}) async {
    throw UnimplementedError('queryCursor not implemented in web database');
  }
  @override
  Future<QueryCursor> rawQueryCursor(String sql, List<Object?>? arguments, {int? bufferSize}) async {
    throw UnimplementedError('rawQueryCursor not implemented in web database');
  }
  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) async {
    throw UnimplementedError('devInvokeMethod not implemented in web database');
  }
  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql, [List<Object?>? arguments]) async {
    throw UnimplementedError('devInvokeSqlMethod not implemented in web database');
  }
}

// Web Transaction class
class WebTransaction implements Transaction {
  final WebDatabase _db;

  WebTransaction(this._db);

  @override
  Database get database => _db;

  @override
  Future<int> insert(String table, Map<String, dynamic> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    return await _db.insert(table, values, nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm);
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<dynamic>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async {
    return await _db.query(table, distinct: distinct, columns: columns, where: where, whereArgs: whereArgs, groupBy: groupBy, having: having, orderBy: orderBy, limit: limit, offset: offset);
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    return await _db.update(table, values, where: where, whereArgs: whereArgs, conflictAlgorithm: conflictAlgorithm);
  }

  @override
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    return await _db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    await _db.execute(sql, arguments);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    return await _db.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    return await _db.rawInsert(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    return await _db.rawUpdate(sql, arguments);
  }

  @override
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    return await _db.rawDelete(sql, arguments);
  }

  @override
  Batch batch() {
    return WebBatch();
  }

  @override
  Future<QueryCursor> queryCursor(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset, int? bufferSize}) async {
    throw UnimplementedError('queryCursor not implemented in web transaction');
  }

  @override
  Future<QueryCursor> rawQueryCursor(String sql, List<Object?>? arguments, {int? bufferSize}) async {
    throw UnimplementedError('rawQueryCursor not implemented in web transaction');
  }
}

// Web Batch class
class WebBatch implements Batch {
  final List<dynamic> _operations = [];

  @override
  int get length => _operations.length;

  @override
  void insert(String table, Map<String, dynamic> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {
    _operations.add({'type': 'insert', 'table': table, 'values': values});
  }

  @override
  void update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) {
    _operations.add({'type': 'update', 'table': table, 'values': values, 'where': where, 'whereArgs': whereArgs});
  }

  @override
  void delete(String table, {String? where, List<dynamic>? whereArgs}) {
    _operations.add({'type': 'delete', 'table': table, 'where': where, 'whereArgs': whereArgs});
  }

  @override
  void execute(String sql, [List<dynamic>? arguments]) {
    _operations.add({'type': 'execute', 'sql': sql, 'arguments': arguments});
  }

  @override
  Future<List<dynamic>> commit({bool? noResult, bool? continueOnError, bool? exclusive}) async {
    print('Web batch commit: ${_operations.length} operations');
    return List.filled(_operations.length, 1);
  }

  @override
  Future<List<dynamic>> apply({bool? noResult, bool? continueOnError, bool? exclusive}) async {
    return await commit(noResult: noResult, continueOnError: continueOnError, exclusive: exclusive);
  }

  @override
  void query(String table, {bool? distinct, List<String>? columns, String? where, List<dynamic>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) {
    _operations.add({'type': 'query', 'table': table, 'where': where, 'whereArgs': whereArgs});
  }

  @override
  void rawDelete(String sql, [List<dynamic>? arguments]) {
    _operations.add({'type': 'rawDelete', 'sql': sql, 'arguments': arguments});
  }

  @override
  void rawInsert(String sql, [List<dynamic>? arguments]) {
    _operations.add({'type': 'rawInsert', 'sql': sql, 'arguments': arguments});
  }

  @override
  void rawQuery(String sql, [List<dynamic>? arguments]) {
    _operations.add({'type': 'rawQuery', 'sql': sql, 'arguments': arguments});
  }

  @override
  void rawUpdate(String sql, [List<dynamic>? arguments]) {
    _operations.add({'type': 'rawUpdate', 'sql': sql, 'arguments': arguments});
  }
}