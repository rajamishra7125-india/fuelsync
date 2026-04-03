# FuelSync - User Manual

## Table of Contents

1. [Getting Started](#1-getting-started)
2. [Authentication](#2-authentication)
3. [Dashboard](#3-dashboard)
4. [Fuel Sales](#4-fuel-sales)
5. [Customer Management](#5-customer-management)
6. [Tank & Inventory](#6-tank--inventory)
7. [Daily Reconciliation](#7-daily-reconciliation)
8. [Shift Management](#8-shift-management)
9. [Maintenance](#9-maintenance)
10. [Reports](#10-reports)
11. [Settings](#11-settings)
12. [Offline Mode](#12-offline-mode)

---

## 1. Getting Started

### 1.1 Installation

1. **Android**: Install the FuelSync APK on your Android device
2. **iOS**: Install via TestFlight or build from source

### 1.2 First Launch

On first launch, you'll see the welcome screen with two options:

- **Admin Registration** - For shop owners setting up their petrol pump
- **Staff PIN Login** - For existing staff members
- **Explore Demo Dashboard** - Try the app without login

### 1.3 Initial Setup (Admin)

As an admin, you'll need to:

1. Register your petrol pump/shop
2. Set up your staff accounts
3. Configure tanks and nozzles
4. Set up connection mode (online/offline)

---

## 2. Authentication

### 2.1 Admin Registration

To register as an admin:

1. Tap **Admin Registration**
2. Enter your shop details:
   - Shop name
   - Phone number
   - Email address
   - Address
3. Create a secure password
4. Complete registration

### 2.2 Staff Login

Staff members login using:

1. Enter your registered phone number
2. Enter your 4-digit PIN
3. Tap **Login**

### 2.3 Role-Based Access

| Role | Permissions |
|------|-------------|
| **Admin** | Full access to all features |
| **Manager** | Sales, reports, reconciliation |
| **Staff** | Sales entry, customer viewing |

---

## 3. Dashboard

The dashboard provides a quick overview of your petrol pump operations.

### 3.1 Dashboard Components

- **Today's Sales Total**: Total revenue for the day
- **Sales Count**: Number of transactions
- **Tank Status**: Current fuel levels with alerts
- **Low Stock Warnings**: Tanks below threshold
- **Pending Reconciliations**: Items needing attention
- **Customers with Credit**: Credit balance overview

### 3.2 Quick Actions

From the dashboard, you can:

- Add new sale
- View all tanks
- Open reconciliation
- Access reports

---

## 4. Fuel Sales

### 4.1 Recording a Sale

1. Navigate to **Sales** → **Add Sale**
2. Select the **Nozzle/Pump**
3. Choose **Fuel Type** (Diesel/Petrol)
4. Enter **Litres** OR **Amount**
5. Select **Payment Mode**:
   - Cash
   - Credit (requires customer selection)
   - UPI
   - Card
6. Optional: Enter **Vehicle Number**
7. For credit sales: Take **Photo Proof**
8. Tap **Complete Sale**

### 4.2 Payment Modes

| Mode | Description |
|------|-------------|
| Cash | Immediate cash payment |
| Credit | Charge to customer account |
| UPI | Unified Payments Interface |
| Card | Credit/Debit card |

### 4.3 Viewing Sales History

1. Go to **Sales** → **Sales History**
2. Filter by date, fuel type, or payment mode
3. View transaction details

---

## 5. Customer Management

### 5.1 Adding a Customer

1. Go to **Customers** → **Add Customer**
2. Enter customer details:
   - Name
   - Phone number
   - Vehicle numbers (can add multiple)
   - Credit limit
3. Tap **Save**

### 5.2 Managing Credit

To record a payment:

1. Go to **Customers** → Select customer
2. Tap **Record Payment**
3. Enter payment amount
4. Choose payment method
5. Confirm payment

### 5.3 Customer Ledger

View complete transaction history:

1. Select customer from list
2. View all transactions
3. See running balance
4. Filter by date range

---

## 6. Tank & Inventory

### 6.1 Viewing Tank Status

1. Go to **Tanks** → **Tank Dashboard**
2. View all tanks with:
   - Current stock level
   - Capacity percentage
   - Fuel type
   - Low stock alerts

### 6.2 Adding Fuel Purchase

1. Navigate to **Tanks** → **Add Fuel**
2. Select the tank
3. Enter:
   - Supplier name
   - Invoice number
   - Quantity (litres)
   - Rate per litre
4. Capture invoice photo
5. Confirm purchase

### 6.3 Tank Information

Each tank displays:

- **Current Stock**: Litres currently in tank
- **Capacity**: Maximum storage capacity
- **Low Stock Alert**: Threshold for warnings
- **Fuel Type**: Diesel, Petrol, etc.

---

## 7. Daily Reconciliation

Daily reconciliation helps track inventory variance and detect discrepancies.

### 7.1 Performing Reconciliation

1. Go to **Reconciliation** → **Daily Closing**
2. Select the **Tank**
3. Enter:
   - Opening stock (from morning)
   - Purchases during the day
   - Closing stock (current dip)
4. Capture **Dip Image** (photo of tank level)
5. Add notes if needed
6. Submit reconciliation

### 7.2 Understanding Results

The system calculates:

- **Expected Stock** = Opening + Purchases - Sales
- **Difference** = Closing - Expected
- **Status** = Normal, Pending, or Theft Alert

### 7.3 Variance Thresholds

| Variance | Status | Action |
|----------|--------|--------|
| < 1% | Normal | No action needed |
| 1-5% | Pending | Review and approve |
| > 5% | Theft Alert | Investigate immediately |

---

## 8. Shift Management

### 8.1 Starting a Shift

1. Go to **Shift** → **Start Shift**
2. Enter opening cash amount
3. Confirm shift start

### 8.2 Ending a Shift

1. Go to **Shift** → **End Shift**
2. Enter closing cash count
3. View variance report
4. Confirm or dispute

### 8.3 Shift Reports

View shift performance:

- Total sales
- Cash collected
- Credit given
- Variance amount

---

## 9. Maintenance

### 9.1 Reporting an Issue

1. Go to **Maintenance** → **Report Issue**
2. Select equipment type:
   - Tank
   - Pump
   - Nozzle
   - Other
3. Enter details:
   - Issue description
   - Priority (Low/Medium/High/Critical)
   - Reported by
4. Submit report

### 9.2 Viewing Maintenance Logs

1. Go to **Maintenance**
2. View all maintenance requests
3. Filter by:
   - Status (Open, In Progress, Resolved)
   - Priority
   - Equipment type

### 9.3 Resolving Issues

1. Select maintenance request
2. Update status to In Progress
3. Add resolution notes
4. Mark as Resolved

---

## 10. Reports

### 10.1 Available Reports

| Report | Description |
|--------|-------------|
| Daily Report | Sales summary for a day |
| Credit Report | Outstanding customer credits |
| Stock Report | Current inventory levels |
| Nozzle Report | Performance by nozzle |
| Shift History | Past shift records |

### 10.2 Generating Reports

1. Select report type
2. Choose date range
3. Apply filters (optional)
4. View/Export report

### 10.3 Export Options

Reports can be:

- Viewed on screen
- Shared via other apps

---

## 11. Settings

### 11.1 Connection Mode

Configure how the app syncs data:

- **Cloud Mode**: Real-time sync with server
- **Offline Mode**: Local-only operation

### 11.2 Managing Staff

As an admin:

1. Go to **Settings** → **Staff Users**
2. Add new staff:
   - Name
   - Phone
   - PIN
   - Role
3. Edit or remove existing staff

### 11.3 Managing Nozzles

1. Go to **Settings** → **Manage Nozzles**
2. Add/edit nozzle:
   - Name/Number
   - Assigned tank
   - Fuel type

### 11.4 Role Permissions

Configure what each role can access:

- Sales: Add/view sales
- Customers: Manage customers
- Reports: View reports
- Reconciliation: Perform closings
- Settings: Modify configurations

---

## 12. Offline Mode

### 12.1 How It Works

FuelSync works offline using local storage:

1. All data is saved to local SQLite database
2. When online, data syncs automatically
3. No internet needed for day-to-day operations

### 12.2 Offline Indicators

When offline, you'll see:

- Offline icon in header
- Sync status message
- Last sync timestamp

### 12.3 Syncing Data

Data syncs automatically:

- Every 30 seconds when online
- Immediately when connectivity returns
- Manual sync available in settings

### 12.4 Conflict Resolution

If same record edited both locally and on server:

- Most recent change wins
- Previous versions are overwritten

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Can't login | Check credentials, verify network |
| Sync not working | Check internet connection |
| App running slow | Clear cache, restart app |
| Missing data | Check if synced properly |

### Getting Help

For support:

- Contact technical support
- Check online documentation
- Submit bug report

---

## Tips & Best Practices

1. **Regular Reconciliation**: Perform daily to catch issues early
2. **Photo Proof**: Always capture for credit transactions
3. **Low Stock Alerts**: Configure appropriate thresholds
4. **Backup**: Regularly export important reports
5. **Staff Training**: Ensure all staff understand the system

---

*FuelSync Version 1.0.0*
*Last Updated: 2024*
