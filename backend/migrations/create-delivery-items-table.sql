-- Migration: Create DeliveryItems table for multi-product delivery support
-- This table allows each delivery to have multiple products with individual quantities and prices

CREATE TABLE IF NOT EXISTS "DeliveryItems" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "deliveryId" UUID NOT NULL REFERENCES "Deliveries"("id") ON DELETE CASCADE,
  "productId" UUID NOT NULL REFERENCES "Products"("id") ON DELETE RESTRICT,
  "quantity" DECIMAL(10, 2) NOT NULL CHECK ("quantity" >= 0),
  "price" DECIMAL(10, 2) NOT NULL CHECK ("price" >= 0),
  "isOneTime" BOOLEAN DEFAULT false,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS "delivery_items_delivery_id_idx" ON "DeliveryItems"("deliveryId");
CREATE INDEX IF NOT EXISTS "delivery_items_product_id_idx" ON "DeliveryItems"("productId");

-- Add comment to table
COMMENT ON TABLE "DeliveryItems" IS 'Stores individual product items for each delivery in multi-product subscriptions';
COMMENT ON COLUMN "DeliveryItems"."isOneTime" IS 'True if this is a one-time addition not part of regular subscription';

