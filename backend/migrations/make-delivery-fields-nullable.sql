-- Migration: Make productId and quantity nullable in Deliveries table
-- This allows multi-product subscriptions where product details are stored in DeliveryItems

-- Step 1: Make productId nullable
ALTER TABLE "Deliveries" ALTER COLUMN "productId" DROP NOT NULL;

-- Step 2: Make quantity nullable
ALTER TABLE "Deliveries" ALTER COLUMN "quantity" DROP NOT NULL;

-- Verify the changes
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'Deliveries' AND column_name IN ('productId', 'quantity');

