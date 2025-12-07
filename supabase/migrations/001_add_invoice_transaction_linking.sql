-- =============================================================================
-- Migration: Add Invoice-Transaction Bidirectional Linking
-- Version: 001
-- Description: Adds transaction_id to invoices table and invoice_id to 
--              transactions table for proper bidirectional linking
-- Requirements: 1.5, 3.4
-- =============================================================================

-- Add transaction_id column to invoices table
ALTER TABLE invoices 
ADD COLUMN IF NOT EXISTS transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL;

-- Add pdf_path column to store generated PDF file path
ALTER TABLE invoices 
ADD COLUMN IF NOT EXISTS pdf_path TEXT;

-- Add pdf_generated_at timestamp to track when PDF was created
ALTER TABLE invoices 
ADD COLUMN IF NOT EXISTS pdf_generated_at TIMESTAMP WITH TIME ZONE;

-- Create index on transaction_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_invoices_transaction_id ON invoices(transaction_id);

-- Add comment for documentation
COMMENT ON COLUMN invoices.transaction_id IS 'Foreign key reference to the originating transaction';
COMMENT ON COLUMN invoices.pdf_path IS 'File path to the generated PDF invoice document';
COMMENT ON COLUMN invoices.pdf_generated_at IS 'Timestamp when the PDF was generated';
