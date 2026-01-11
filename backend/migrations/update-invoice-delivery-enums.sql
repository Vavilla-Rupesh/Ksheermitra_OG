-- Migration: Update Invoice enum types to support delivery boy invoices
-- This migration adds 'delivery_boy_daily' to invoice type and 'generated' to status

-- Add new invoice type
ALTER TYPE "enum_Invoices_type" RENAME TO "enum_Invoices_type_old";
CREATE TYPE "enum_Invoices_type" AS ENUM ('daily', 'monthly', 'delivery_boy_daily');
ALTER TABLE "Invoices"
  ALTER COLUMN "type" TYPE "enum_Invoices_type"
  USING "type"::text::"enum_Invoices_type";
DROP TYPE "enum_Invoices_type_old";

-- Rename column from 'type' to 'invoiceType' for clarity (if needed)
-- ALTER TABLE "Invoices" RENAME COLUMN "type" TO "invoiceType";

-- Add 'generated' status to invoice status enum
ALTER TYPE "enum_Invoices_paymentStatus" RENAME TO "enum_Invoices_status_old";
CREATE TYPE "enum_Invoices_status" AS ENUM ('pending', 'generated', 'sent', 'paid', 'partial');
ALTER TABLE "Invoices"
  ALTER COLUMN "paymentStatus" TYPE "enum_Invoices_status"
  USING "paymentStatus"::text::"enum_Invoices_status";
DROP TYPE "enum_Invoices_status_old";

-- Rename column from 'paymentStatus' to 'status' for consistency (if needed)
-- ALTER TABLE "Invoices" RENAME COLUMN "paymentStatus" TO "status";

-- Rename column from 'deliveryDetails' to 'metadata' for flexibility (if needed)
-- ALTER TABLE "Invoices" RENAME COLUMN "deliveryDetails" TO "metadata";

-- Add 'in-progress' and 'failed' to delivery status enum
ALTER TYPE "enum_Deliveries_status" RENAME TO "enum_Deliveries_status_old";
CREATE TYPE "enum_Deliveries_status" AS ENUM ('pending', 'in-progress', 'delivered', 'missed', 'cancelled', 'failed');
ALTER TABLE "Deliveries"
  ALTER COLUMN "status" TYPE "enum_Deliveries_status"
  USING "status"::text::"enum_Deliveries_status";
DROP TYPE "enum_Deliveries_status_old";

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS "invoices_delivery_boy_id_date_idx" ON "Invoices"("deliveryBoyId", "invoiceDate");
CREATE INDEX IF NOT EXISTS "deliveries_status_date_idx" ON "Deliveries"("status", "deliveryDate");

COMMENT ON COLUMN "Invoices"."type" IS 'Type of invoice: daily (customer), monthly (customer), or delivery_boy_daily';
COMMENT ON COLUMN "Invoices"."metadata" IS 'Flexible JSONB field for storing additional invoice data';

