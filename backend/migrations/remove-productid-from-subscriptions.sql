-- Migration: Remove productId column from Subscriptions table
-- This migration removes the old productId column since we now use SubscriptionProducts table for multi-product support

-- Step 1: Drop the foreign key constraint if it exists
ALTER TABLE "Subscriptions" DROP CONSTRAINT IF EXISTS "Subscriptions_productId_fkey";

-- Step 2: Drop the productId column
ALTER TABLE "Subscriptions" DROP COLUMN IF EXISTS "productId";

-- Verify the change
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'Subscriptions';

