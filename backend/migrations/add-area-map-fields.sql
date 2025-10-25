-- Add Google Maps support to Areas table
-- Migration: add-area-map-fields.sql

-- Add boundaries column for polygon coordinates
ALTER TABLE "Areas"
ADD COLUMN IF NOT EXISTS "boundaries" JSONB,
ADD COLUMN IF NOT EXISTS "centerLatitude" DECIMAL(10, 8),
ADD COLUMN IF NOT EXISTS "centerLongitude" DECIMAL(11, 8),
ADD COLUMN IF NOT EXISTS "mapLink" TEXT;

-- Add comment for boundaries column
COMMENT ON COLUMN "Areas"."boundaries" IS 'Array of {lat, lng} coordinates defining the area polygon';

-- Create index on boundaries for faster queries
CREATE INDEX IF NOT EXISTS "idx_areas_boundaries" ON "Areas" USING GIN ("boundaries");

-- Log the migration
DO $$
BEGIN
  RAISE NOTICE 'Migration completed: Added Google Maps fields to Areas table';
END $$;

