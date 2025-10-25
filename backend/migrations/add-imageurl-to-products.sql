-- Migration: Add imageUrl column to Products table
-- Date: 2025-01-22

-- Add imageUrl column to Products table
ALTER TABLE "Products"
ADD COLUMN "imageUrl" VARCHAR(255);

-- Add comment to the column
COMMENT ON COLUMN "Products"."imageUrl" IS 'Relative URL path to the product image';

