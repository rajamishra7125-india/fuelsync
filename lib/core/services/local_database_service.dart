import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fuelsync_local.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        // Offline sales table
        await db.execute('''
          CREATE TABLE offline_sales (
            id TEXT PRIMARY KEY,
            nozzle_id TEXT,
            fuel_type TEXT,
            rate REAL,
            litres REAL,
            amount REAL,
            payment_type TEXT,
            vehicle_number TEXT,
            image_path TEXT,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        // Offline purchases table
        await db.execute('''
          CREATE TABLE offline_purchases (
            id TEXT PRIMARY KEY,
            tank_id TEXT,
            supplier TEXT,
            invoice_number TEXT,
            quantity REAL,
            rate REAL,
            image_path TEXT,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        // Offline customers table
        await db.execute('''
          CREATE TABLE offline_customers (
            id TEXT PRIMARY KEY,
            name TEXT,
            phone TEXT,
            vehicle_numbers TEXT,
            credit_limit REAL,
            balance REAL,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        // Offline shifts table
        await db.execute('''
          CREATE TABLE offline_shifts (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            opening_cash REAL,
            closing_cash REAL,
            status TEXT,
            start_time TEXT,
            end_time TEXT,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        // Offline nozzle readings table
        await db.execute('''
          CREATE TABLE offline_nozzle_readings (
            id TEXT PRIMARY KEY,
            nozzle_id TEXT,
            shift_id TEXT,
            opening_reading REAL,
            closing_reading REAL,
            total_sales REAL,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        // Offline reconciliations table
        await db.execute('''
          CREATE TABLE offline_reconciliations (
            id TEXT PRIMARY KEY,
            tank_id TEXT,
            date TEXT,
            opening_stock REAL,
            purchases REAL,
            sales REAL,
            expected_stock REAL,
            closing_stock REAL,
            difference REAL,
            status TEXT,
            dip_image_url TEXT,
            notes TEXT,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        // Offline maintenance logs table
        await db.execute('''
          CREATE TABLE offline_maintenance_logs (
            id TEXT PRIMARY KEY,
            equipment_type TEXT,
            equipment_id TEXT,
            issue_description TEXT,
            status TEXT,
            priority TEXT,
            reported_by TEXT,
            assigned_to TEXT,
            resolution_notes TEXT,
            resolved_at TEXT,
            is_synced INTEGER DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');

        // Sync metadata table
        await db.execute('''
          CREATE TABLE sync_metadata (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');

        // Local data cache (for pulled data from server)
        await db.execute('''
          CREATE TABLE local_data (
            id TEXT PRIMARY KEY,
            table_name TEXT,
            data TEXT,
            updated_at TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Migration logic for v3
        }
      },
    );
  }

  // ============================================
  // 💾 SAVE OPERATIONS
  // ============================================

  Future<void> saveOfflineSale(Map<String, dynamic> sale) async {
    final db = await database;
    await db.insert(
      'offline_sales',
      sale,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveOfflinePurchase(Map<String, dynamic> purchase) async {
    final db = await database;
    await db.insert(
      'offline_purchases',
      purchase,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveOfflineCustomer(Map<String, dynamic> customer) async {
    final db = await database;
    await db.insert(
      'offline_customers',
      customer,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveOfflineShift(Map<String, dynamic> shift) async {
    final db = await database;
    await db.insert(
      'offline_shifts',
      shift,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveOfflineNozzleReading(Map<String, dynamic> reading) async {
    final db = await database;
    await db.insert(
      'offline_nozzle_readings',
      reading,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveOfflineReconciliation(Map<String, dynamic> rec) async {
    final db = await database;
    await db.insert(
      'offline_reconciliations',
      rec,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveOfflineMaintenanceLog(Map<String, dynamic> log) async {
    final db = await database;
    await db.insert(
      'offline_maintenance_logs',
      log,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================
  // 📤 GET UNSYNCED RECORDS (For Push to Server)
  // ============================================

  Future<List<Map<String, dynamic>>> getUnsyncedSales() async {
    final db = await database;
    return await db.query(
      'offline_sales',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedPurchases() async {
    final db = await database;
    return await db.query(
      'offline_purchases',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedCustomers() async {
    final db = await database;
    return await db.query(
      'offline_customers',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedShifts() async {
    final db = await database;
    return await db.query(
      'offline_shifts',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedNozzleReadings() async {
    final db = await database;
    return await db.query(
      'offline_nozzle_readings',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedReconciliations() async {
    final db = await database;
    return await db.query(
      'offline_reconciliations',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedMaintenanceLogs() async {
    final db = await database;
    return await db.query(
      'offline_maintenance_logs',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  // ============================================
  // ✅ MARK AS SYNCED
  // ============================================

  Future<void> markSynced(String table, String id) async {
    final db = await database;
    await db.update(table, {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ============================================
  // 🔄 SYNC METADATA (Last Sync Time)
  // ============================================

  Future<String?> getLastSyncTime() async {
    final db = await database;
    final result = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: ['last_sync_time'],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  Future<void> setLastSyncTime(String timestamp) async {
    final db = await database;
    await db.insert('sync_metadata', {
      'key': 'last_sync_time',
      'value': timestamp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ============================================
  // 📥 PULL DATA FROM SERVER (Upsert)
  // ============================================

  Future<void> upsert(String table, Map<String, dynamic> record) async {
    final db = await database;
    final data = Map<String, dynamic>.from(record);
    data['updated_at'] = DateTime.now().toIso8601String();

    await db.insert('local_data', {
      'id': record['id'],
      'table_name': table,
      'data': data.toString(),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getRecordById(String table, String id) async {
    final db = await database;
    final result = await db.query(
      'local_data',
      where: 'id = ? AND table_name = ?',
      whereArgs: [id, table],
    );
    if (result.isNotEmpty) {
      // Return the raw record
      return result.first;
    }
    return null;
  }

  // ============================================
  // 📊 GET LOCAL DATA FOR QUERIES
  // ============================================

  Future<List<Map<String, dynamic>>> getLocalSales({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    String where = "table_name = 'fuel_sales'";
    List<dynamic> whereArgs = ['fuel_sales'];

    if (startDate != null) {
      where += " AND updated_at >= ?";
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      where += " AND updated_at <= ?";
      whereArgs.add(endDate.toIso8601String());
    }

    return await db.query('local_data', where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> getLocalTanks() async {
    final db = await database;
    return await db.query(
      'local_data',
      where: 'table_name = ?',
      whereArgs: ['tanks'],
    );
  }

  Future<List<Map<String, dynamic>>> getLocalCustomers() async {
    final db = await database;
    return await db.query(
      'local_data',
      where: 'table_name = ?',
      whereArgs: ['customers'],
    );
  }

  // ============================================
  // 🧹 CLEANUP OPERATIONS
  // ============================================

  Future<void> clearSyncedData() async {
    final db = await database;
    await db.execute('DELETE FROM offline_sales WHERE is_synced = 1');
    await db.execute('DELETE FROM offline_purchases WHERE is_synced = 1');
    await db.execute('DELETE FROM offline_customers WHERE is_synced = 1');
    await db.execute('DELETE FROM offline_shifts WHERE is_synced = 1');
    await db.execute('DELETE FROM offline_nozzle_readings WHERE is_synced = 1');
    await db.execute('DELETE FROM offline_reconciliations WHERE is_synced = 1');
    await db.execute(
      'DELETE FROM offline_maintenance_logs WHERE is_synced = 1',
    );
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('offline_sales');
    await db.delete('offline_purchases');
    await db.delete('offline_customers');
    await db.delete('offline_shifts');
    await db.delete('offline_nozzle_readings');
    await db.delete('offline_reconciliations');
    await db.delete('offline_maintenance_logs');
    await db.delete('local_data');
    await db.delete('sync_metadata');
  }
}
