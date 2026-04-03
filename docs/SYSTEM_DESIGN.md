# FuelSync - System Design Documentation

## 1. Overview

**FuelSync** is a comprehensive Flutter-based petrol pump management system designed to streamline fuel sales, inventory management, customer credit tracking, and daily reconciliation operations. The application supports both online and offline modes with automatic synchronization.

### 1.1 Core Objectives
- Real-time fuel sales tracking and management
- Offline-capable operations with automatic sync
- Multi-user support with role-based access
- Comprehensive reporting and analytics
- Inventory and tank management

---

## 2. Architecture

### 2.1 Technology Stack

| Component | Technology |
|-----------|------------|
| Frontend | Flutter 3.x |
| State Management | Riverpod 2.x |
| Backend | Supabase (PostgreSQL) |
| Local Database | SQLite (sqflite) |
| Authentication | Supabase Auth |
| Storage | Supabase Storage |
| Connectivity | connectivity_plus |

### 2.2 Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── models/                  # Data models
│   │   ├── customer.dart
│   │   ├── petrol_pump.dart
│   │   ├── reconciliation.dart
│   │   ├── shift.dart
│   │   └── tank.dart
│   ├── services/                # Core services
│   │   ├── supabase_service.dart     # API layer
│   │   ├── local_database_service.dart # SQLite operations
│   │   ├── sync_manager.dart          # Offline sync
│   │   └── storage_service.dart       # Local preferences
│   ├── theme/                   # App theming
│   ├── widgets/                 # Reusable widgets
│   └── storage/                 # Storage utilities
├── data/
│   ├── datasources/            # Data sources
│   ├── models/                 # Data models
│   └── repositories/           # Repository pattern
├── domain/
│   └── entities/               # Domain entities
├── features/                   # Feature modules
│   ├── auth/                   # Authentication
│   ├── dashboard/              # Main dashboard
│   ├── sales/                 # Fuel sales
│   ├── customer/               # Customer management
│   ├── tank/                   # Tank management
│   ├── reconciliation/         # Daily reconciliation
│   ├── maintenance/            # Equipment maintenance
│   ├── reports/                # Reporting
│   ├── settings/               # App settings
│   └── shift/                  # Shift management
└── presentation/
    └── controllers/            # UI controllers
```

### 2.3 Architecture Pattern

The application follows **Clean Architecture** with three main layers:

1. **Presentation Layer** - UI widgets, screens, and controllers
2. **Domain Layer** - Business entities and use cases
3. **Data Layer** - Repositories, data sources, and models

---

## 3. Data Flow & Services

### 3.1 Supabase Service [`supabase_service.dart`]

The core API layer that handles all database operations:

```dart
class SupabaseService {
  // Generic CRUD operations
  Future<Map<String, dynamic>?> insert(String table, Map<String, dynamic> data)
  Future<List<Map<String, dynamic>>> fetchAll(String table)
  Future<List<Map<String, dynamic>>> fetchByShop(String table, String shopId)
  Future<Map<String, dynamic>?> update(String table, String id, Map<String, dynamic> data)
  Future<void> delete(String table, String id)
  
  // Specialized operations
  Future<List<Map<String, dynamic>>> getTodaySales(String shopId)
  Future<List<Map<String, dynamic>>> getTanks(String shopId)
  Future<Map<String, dynamic>> getDashboardData(String shopId)
  
  // Storage operations
  Future<String> uploadProof(String filePath, String bucket)
}
```

### 3.2 Local Database Service [`local_database_service.dart`]

SQLite-based offline storage with the following tables:

| Table | Purpose |
|-------|---------|
| `offline_sales` | Unsynced fuel sales |
| `offline_purchases` | Unsynced fuel purchases |
| `offline_customers` | Unsynced customer records |
| `offline_shifts` | Unsynced shift records |
| `offline_nozzle_readings` | Unsynced nozzle readings |
| `offline_reconciliations` | Unsynced reconciliations |
| `offline_maintenance_logs` | Unsynced maintenance logs |

### 3.3 Sync Manager [`sync_manager.dart`]

Smart synchronization system with the following features:

- **Auto-sync**: Runs every 30 seconds when online
- **Delta Sync**: Only syncs records modified since last sync
- **Conflict Resolution**: "Last Updated Wins" strategy
- **Connectivity Monitoring**: Listens for network changes

```
Sync Flow:
1. Push local pending data → Server
2. Pull server updates → Local
3. Resolve conflicts (Last Updated Wins)
4. Update last sync timestamp
```

---

## 4. Key Features

### 4.1 Authentication System

- **Admin Registration**: Shop owner creates admin account
- **Staff Login**: PIN-based authentication for staff
- **Role Management**: Admin, Manager, Staff roles with permissions
- **Session Management**: Supabase Auth integration

### 4.2 Fuel Sales

- Quick sale entry with fuel type selection
- Multiple payment modes (Cash, Credit, UPI, Card)
- Vehicle number capture
- Photo proof for credit sales
- Real-time inventory deduction

### 4.3 Customer Management

- Customer registration with vehicle numbers
- Credit limit management
- Credit balance tracking
- Payment recording
- Customer ledger viewing

### 4.4 Tank & Inventory Management

- Multiple tank support (Diesel, Petrol variants)
- Stock level monitoring with low-stock alerts
- Purchase recording with invoice capture
- Daily stock reconciliation

### 4.5 Daily Reconciliation

- Opening and closing stock entry
- Dip image capture
- Variance calculation
- Theft detection alerts
- Daily closing reports

### 4.6 Shift Management

- Shift opening/closing with cash recording
- Cash variance tracking
- Shift history viewing
- Staff performance analysis

### 4.7 Maintenance

- Equipment tracking (tanks, pumps, nozzles)
- Issue reporting
- Priority levels (Low, Medium, High, Critical)
- Resolution tracking

### 4.8 Reports & Analytics

- Daily sales reports
- Credit reports
- Stock reports
- Nozzle performance reports
- Shift history reports

---

## 5. Data Models

### 5.1 Core Entities

```dart
// Customer
{
  id: String,
  name: String,
  phone: String,
  vehicle_numbers: List<String>,
  credit_limit: double,
  current_balance: double,
  shop_id: String
}

// Tank
{
  id: String,
  name: String,
  fuel_type: String, // Diesel, Petrol
  capacity: double,
  current_stock: double,
  low_stock_alert: double,
  shop_id: String
}

// Fuel Sale
{
  id: String,
  nozzle_id: String,
  fuel_type: String,
  rate: double,
  litres: double,
  amount: double,
  payment_mode: String,
  vehicle_number: String?,
  customer_proof_url: String?,
  shop_id: String
}

// Reconciliation
{
  id: String,
  tank_id: String,
  date: DateTime,
  opening_stock: double,
  purchases: double,
  sales: double,
  expected_stock: double,
  closing_stock: double,
  difference: double,
  status: String, // normal, pending, theft
  dip_image_url: String?,
  shop_id: String
}
```

---

## 6. Offline Capability

### 6.1 How Offline Mode Works

1. **Local-First Architecture**: All data operations write to SQLite first
2. **Queue System**: Unsynced records are queued with timestamps
3. **Auto-Sync**: When connectivity returns, sync runs automatically
4. **Conflict Resolution**: Server timestamp determines winner

### 6.2 Connection Modes

| Mode | Behavior |
|------|----------|
| Offline | SQLite only, no sync |
| Local | Future LAN server sync |
| Cloud | Full Supabase sync enabled |

---

## 7. Security

- Row-Level Security (RLS) in Supabase
- JWT-based authentication
- Role-based access control
- Secure storage for sensitive data

---

## 8. Dependencies

### 8.1 Core Dependencies

```yaml
dependencies:
  flutter_riverpod: ^3.3.1    # State management
  supabase_flutter: ^2.12.0   # Backend
  sqflite: ^2.4.2             # Local database
  connectivity_plus: ^7.0.0   # Network monitoring
  image_picker: ^1.2.1        # Photo capture
  fl_chart: ^1.2.0            # Charts
  intl: ^0.20.2               # Date/number formatting
  shared_preferences: ^2.5.4  # Key-value storage
  google_fonts: ^8.0.2        # Typography
```

---

## 9. API Endpoints (Supabase)

### 9.1 Tables

- `shops` - Petrol pump/company info
- `users` - Staff accounts
- `customers` - Customer records
- `tanks` - Fuel tank inventory
- `nozzles` - Dispenser nozzles
- `fuel_sales` - Sales transactions
- `inventory_logs` - Purchases
- `daily_reconciliation` - Reconciliation records
- `shifts` - Shift records
- `maintenance_logs` - Maintenance records

---

## 10. Future Enhancements

- SMS/Email notifications
- Multi-language support
- Advanced analytics dashboard
- GPS tracking integration
- Invoice generation
- Tax compliance reporting
