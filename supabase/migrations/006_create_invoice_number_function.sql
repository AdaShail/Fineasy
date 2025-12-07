-- Migration: Create Invoice Number Generation Function
-- Description: Creates a database function to generate sequential invoice numbers
-- Date: 2025-11-13

-- Drop function if exists
DROP FUNCTION IF EXISTS generate_invoice_number(UUID, TEXT);

-- Create function to generate invoice numbers
CREATE OR REPLACE FUNCTION generate_invoice_number(
    business_uuid UUID,
    invoice_prefix TEXT DEFAULT 'INV'
)
RETURNS TEXT AS $$
DECLARE
    max_number INTEGER;
    next_number INTEGER;
    new_invoice_number TEXT;
BEGIN
    -- Get the maximum invoice number for this business with this prefix
    -- Use table alias to avoid ambiguous column reference
    SELECT COALESCE(
        MAX(
            CAST(
                SUBSTRING(
                    i.invoice_number FROM LENGTH(invoice_prefix) + 2
                ) AS INTEGER
            )
        ),
        0
    )
    INTO max_number
    FROM invoices i
    WHERE i.business_id = business_uuid
    AND i.invoice_number LIKE invoice_prefix || '-%';
    
    -- Calculate next number
    next_number := max_number + 1;
    
    -- Format invoice number with leading zeros (4 digits)
    -- Use different variable name to avoid ambiguity
    new_invoice_number := invoice_prefix || '-' || LPAD(next_number::TEXT, 4, '0');
    
    RETURN new_invoice_number;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION generate_invoice_number(UUID, TEXT) TO authenticated;

-- Add comment
COMMENT ON FUNCTION generate_invoice_number IS 'Generates sequential invoice numbers for a business with a given prefix';
