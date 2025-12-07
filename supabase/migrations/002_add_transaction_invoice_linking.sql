-- =============================================================================
-- Migration: Add Invoice Reference to Transactions
-- Version: 002
-- Description: Adds invoice_id to transactions table for bidirectional linking
--              between transactions and invoices
-- Requirements: 1.5
-- =============================================================================

-- Add invoice_id column to transactions table
ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL;

-- Create index on invoice_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_transactions_invoice_id ON transactions(invoice_id);

-- Add comment for documentation
COMMENT ON COLUMN transactions.invoice_id IS 'Foreign key reference to the generated invoice for this transaction';
