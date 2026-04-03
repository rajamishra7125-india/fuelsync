-- ========================================================
-- FuelSync Supabase Migration Script (FINAL - FIXED)
-- Run this directly in the Supabase SQL Editor
-- ========================================================
-- Enable required extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- ========================================================
-- CUSTOM ENUM TYPES
-- ========================================================
DROP TYPE IF EXISTS user_role CASCADE;
DROP TYPE IF EXISTS fuel_type CASCADE;
DROP TYPE IF EXISTS payment_status CASCADE;
DROP TYPE IF EXISTS sync_status CASCADE;
CREATE TYPE user_role AS ENUM ('Admin', 'Manager', 'Operator', 'Accountant');
CREATE TYPE fuel_type AS ENUM ('Petrol', 'Diesel', 'CNG');
CREATE TYPE payment_status AS ENUM ('pending', 'confirmed', 'failed');
CREATE TYPE sync_status AS ENUM ('pending', 'synced', 'deleted');
-- ========================================================
-- TABLE: shops (Multi-Company Support)
-- ========================================================
DROP TABLE IF EXISTS shops CASCADE;
CREATE TABLE shops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    address TEXT,
    gst_number TEXT,
    phone TEXT,
    shop_code TEXT UNIQUE,
    sync_status sync_status DEFAULT 'synced',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: users (Staff with PIN Login)
-- ========================================================
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT,
    role user_role NOT NULL,
    pin TEXT,
    is_active BOOLEAN DEFAULT true,
    sync_status sync_status DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: tanks
-- ========================================================
DROP TABLE IF EXISTS tanks CASCADE;
CREATE TABLE tanks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    name TEXT NOT NULL,
    type fuel_type NOT NULL,
    capacity DECIMAL(10, 2) NOT NULL,
    current_stock DECIMAL(10, 2) NOT NULL DEFAULT 0,
    low_stock_alert DECIMAL(10, 2) DEFAULT 50,
    last_dip_date DATE,
    last_dip_reading DECIMAL(10, 2),
    sync_status sync_status DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: nozzles
-- ========================================================
DROP TABLE IF EXISTS nozzles CASCADE;
CREATE TABLE nozzles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    tank_id UUID REFERENCES tanks(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    dispenser_number TEXT,
    sync_status sync_status DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: shifts
-- ========================================================
DROP TABLE IF EXISTS shifts CASCADE;
CREATE TABLE shifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE
    SET NULL,
        start_time TIMESTAMPTZ DEFAULT NOW(),
        end_time TIMESTAMPTZ,
        opening_cash DECIMAL(10, 2) DEFAULT 0,
        closing_cash DECIMAL(10, 2) DEFAULT 0,
        status TEXT DEFAULT 'Open',
        sync_status sync_status DEFAULT 'pending',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: nozzle_readings (Meter readings per shift)
-- ========================================================
DROP TABLE IF EXISTS nozzle_readings CASCADE;
CREATE TABLE nozzle_readings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    nozzle_id UUID REFERENCES nozzles(id) ON DELETE CASCADE,
    shift_id UUID REFERENCES shifts(id) ON DELETE CASCADE,
    opening_reading DECIMAL(10, 2) NOT NULL,
    closing_reading DECIMAL(10, 2),
    total_sales DECIMAL(10, 2) DEFAULT 0,
    sync_status sync_status DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: fuel_sales (Main Sales Table)
-- ========================================================
DROP TABLE IF EXISTS fuel_sales CASCADE;
CREATE TABLE fuel_sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    nozzle_id UUID REFERENCES nozzles(id) ON DELETE
    SET NULL,
        shift_id UUID REFERENCES shifts(id) ON DELETE
    SET NULL,
        vehicle_number TEXT,
        customer_name TEXT,
        fuel_type TEXT NOT NULL,
        rate DECIMAL(10, 2) NOT NULL,
        litres DECIMAL(10, 2) NOT NULL,
        amount DECIMAL(10, 2) NOT NULL,
        payment_mode TEXT NOT NULL,
        payment_status payment_status DEFAULT 'pending',
        reference_number TEXT,
        customer_proof_url TEXT,
        sync_status sync_status DEFAULT 'pending',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: inventory_logs (Fuel Purchases/Supply)
-- ========================================================
DROP TABLE IF EXISTS inventory_logs CASCADE;
CREATE TABLE inventory_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    tank_id UUID REFERENCES tanks(id) ON DELETE
    SET NULL,
        supplier TEXT NOT NULL,
        invoice_number TEXT,
        quantity DECIMAL(10, 2) NOT NULL,
        rate DECIMAL(10, 2) NOT NULL,
        total_amount DECIMAL(10, 2),
        type TEXT DEFAULT 'PURCHASE',
        proof_url TEXT,
        sync_status sync_status DEFAULT 'pending',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: daily_reconciliation (Anti-Theft System)
-- ========================================================
DROP TABLE IF EXISTS daily_reconciliation CASCADE;
CREATE TABLE daily_reconciliation (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    tank_id UUID REFERENCES tanks(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    opening_stock DECIMAL(10, 2) NOT NULL,
    purchases DECIMAL(10, 2) DEFAULT 0,
    sales DECIMAL(10, 2) DEFAULT 0,
    expected_stock DECIMAL(10, 2) NOT NULL,
    closing_stock DECIMAL(10, 2),
    difference DECIMAL(10, 2),
    status TEXT DEFAULT 'pending',
    dip_image_url TEXT,
    notes TEXT,
    sync_status sync_status DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: customers (Credit System)
-- ========================================================
DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    name TEXT NOT NULL,
    phone TEXT,
    vehicle_numbers TEXT [],
    credit_limit DECIMAL(10, 2) DEFAULT 0,
    current_balance DECIMAL(10, 2) DEFAULT 0,
    sync_status sync_status DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: credit_transactions
-- ========================================================
DROP TABLE IF EXISTS credit_transactions CASCADE;
CREATE TABLE credit_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    sale_id UUID REFERENCES fuel_sales(id) ON DELETE
    SET NULL,
        amount_dr DECIMAL(10, 2) DEFAULT 0,
        amount_cr DECIMAL(10, 2) DEFAULT 0,
        type TEXT NOT NULL,
        notes TEXT,
        sync_status sync_status DEFAULT 'pending',
        created_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- TABLE: maintenance_logs
-- ========================================================
DROP TABLE IF EXISTS maintenance_logs CASCADE;
CREATE TABLE maintenance_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    equipment_type TEXT NOT NULL,
    equipment_id UUID,
    issue_description TEXT NOT NULL,
    status TEXT DEFAULT 'open',
    priority TEXT DEFAULT 'medium',
    reported_by UUID REFERENCES users(id) ON DELETE
    SET NULL,
        assigned_to TEXT,
        resolved_by UUID REFERENCES users(id) ON DELETE
    SET NULL,
        resolution_notes TEXT,
        sync_status sync_status DEFAULT 'pending',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        resolved_at TIMESTAMPTZ
);
-- ========================================================
-- TABLE: invoices (GST System)
-- ========================================================
DROP TABLE IF EXISTS invoices CASCADE;
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id TEXT NOT NULL,
    sale_id UUID REFERENCES fuel_sales(id) ON DELETE
    SET NULL,
        invoice_number TEXT NOT NULL UNIQUE,
        invoice_type TEXT DEFAULT 'normal',
        customer_name TEXT,
        customer_gstin TEXT,
        vehicle_number TEXT,
        fuel_type TEXT NOT NULL,
        litres DECIMAL(10, 2) NOT NULL,
        rate DECIMAL(10, 2) NOT NULL,
        base_amount DECIMAL(10, 2) NOT NULL,
        cgst DECIMAL(10, 2) DEFAULT 0,
        sgst DECIMAL(10, 2) DEFAULT 0,
        igst DECIMAL(10, 2) DEFAULT 0,
        total_amount DECIMAL(10, 2) NOT NULL,
        sync_status sync_status DEFAULT 'pending',
        created_at TIMESTAMPTZ DEFAULT NOW()
);
-- ========================================================
-- STORAGE BUCKET (Skip if already exists)
-- ========================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('fuelsync_proofs', 'fuelsync_proofs', true) ON CONFLICT (id) DO NOTHING;
-- ========================================================
-- ENABLE RLS ON ALL TABLES
-- ========================================================
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tanks ENABLE ROW LEVEL SECURITY;
ALTER TABLE nozzles ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE nozzle_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE fuel_sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_reconciliation ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
-- ========================================================
-- RLS POLICIES (Use OR IGNORE to prevent conflicts)
-- ========================================================
DROP POLICY IF EXISTS "Allow all for shops" ON shops;
CREATE POLICY "Allow all for shops" ON shops FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for users" ON users;
CREATE POLICY "Allow all for users" ON users FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for tanks" ON tanks;
CREATE POLICY "Allow all for tanks" ON tanks FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for nozzles" ON nozzles;
CREATE POLICY "Allow all for nozzles" ON nozzles FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for shifts" ON shifts;
CREATE POLICY "Allow all for shifts" ON shifts FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for nozzle_readings" ON nozzle_readings;
CREATE POLICY "Allow all for nozzle_readings" ON nozzle_readings FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for fuel_sales" ON fuel_sales;
CREATE POLICY "Allow all for fuel_sales" ON fuel_sales FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for inventory_logs" ON inventory_logs;
CREATE POLICY "Allow all for inventory_logs" ON inventory_logs FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for daily_reconciliation" ON daily_reconciliation;
CREATE POLICY "Allow all for daily_reconciliation" ON daily_reconciliation FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for customers" ON customers;
CREATE POLICY "Allow all for customers" ON customers FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for credit_transactions" ON credit_transactions;
CREATE POLICY "Allow all for credit_transactions" ON credit_transactions FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for maintenance_logs" ON maintenance_logs;
CREATE POLICY "Allow all for maintenance_logs" ON maintenance_logs FOR ALL TO authenticated USING (true);
DROP POLICY IF EXISTS "Allow all for invoices" ON invoices;
CREATE POLICY "Allow all for invoices" ON invoices FOR ALL TO authenticated USING (true);
-- Storage policies (skip if exists)
DROP POLICY IF EXISTS "Public Proofs" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;
CREATE POLICY "Public Proofs" ON storage.objects FOR
SELECT USING (bucket_id = 'fuelsync_proofs');
CREATE POLICY "Authenticated Upload" ON storage.objects FOR
INSERT TO authenticated WITH CHECK (bucket_id = 'fuelsync_proofs');
-- ========================================================
-- INDEXES FOR PERFORMANCE
-- ========================================================
CREATE INDEX IF NOT EXISTS idx_fuel_sales_shop ON fuel_sales(shop_id);
CREATE INDEX IF NOT EXISTS idx_fuel_sales_created ON fuel_sales(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fuel_sales_sync ON fuel_sales(sync_status);
CREATE INDEX IF NOT EXISTS idx_tanks_shop ON tanks(shop_id);
CREATE INDEX IF NOT EXISTS idx_users_shop ON users(shop_id);
CREATE INDEX IF NOT EXISTS idx_shifts_shop ON shifts(shop_id);
CREATE INDEX IF NOT EXISTS idx_shifts_status ON shifts(status);
CREATE INDEX IF NOT EXISTS idx_nozzle_readings_shift ON nozzle_readings(shift_id);
CREATE INDEX IF NOT EXISTS idx_customers_shop ON customers(shop_id);
CREATE INDEX IF NOT EXISTS idx_daily_reconciliation_shop_date ON daily_reconciliation(shop_id, date);
CREATE INDEX IF NOT EXISTS idx_inventory_logs_shop ON inventory_logs(shop_id);
CREATE INDEX IF NOT EXISTS idx_inventory_logs_created ON inventory_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_customer ON credit_transactions(customer_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_logs_shop ON maintenance_logs(shop_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_logs_status ON maintenance_logs(status);
CREATE INDEX IF NOT EXISTS idx_invoices_shop ON invoices(shop_id);
-- ========================================================
-- FINAL MESSAGE
-- ========================================================
SELECT 'FuelSync Migration Complete! 13 tables, 16 indexes, all policies created.' as status;