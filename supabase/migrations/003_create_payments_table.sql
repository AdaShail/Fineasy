-- =============================================================================
-- Migration: Create Payments Table
-- Version: 003
-- Description: Creates a comprehensive payments table for tracking all payment
--              records against invoices with full payment history
-- Requirements: 6.3, 6.4
-- =============================================================================

-- Drop table if exists to recreate with correct schema
DROP TABLE IF EXISTS payments CASCADE;

-- Create payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    invoice_id UUID REFERENCES invoices(id) ON DELETE CASCADE,
    transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    
    -- Payment details
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    payment_mode TEXT NOT NULL CHECK (payment_mode IN (
        'cash',
        'upi',
        'bank_transfer',
        'cheque',
        'card',
        'online',
        'other'
    )),
    status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN (
        'pending',
        'completed',
        'failed',
        'cancelled'
    )),
    payment_date TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Additional information
    reference TEXT, -- Payment reference number (transaction ID, cheque number, etc.)
    notes TEXT, -- Additional notes about the payment
    receipt_url TEXT, -- URL to payment receipt if available
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_payment_date CHECK (payment_date <= NOW())
);

-- Create indexes for performance
CREATE INDEX idx_payments_invoice_id ON payments(invoice_id);
CREATE INDEX idx_payments_customer_id ON payments(customer_id);
CREATE INDEX idx_payments_supplier_id ON payments(supplier_id);
CREATE INDEX idx_payments_business_id ON payments(business_id);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);
CREATE INDEX idx_payments_status ON payments(status);

-- Create composite index for common queries
CREATE INDEX idx_payments_business_customer ON payments(business_id, customer_id);
CREATE INDEX idx_payments_business_date ON payments(business_id, payment_date DESC);

-- Enable Row Level Security
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view payments for their business
CREATE POLICY "Users can view their business payments" ON payments
    FOR SELECT USING (
        business_id IN (
            SELECT business_id FROM user_profiles WHERE id = auth.uid()
        )
    );

-- RLS Policy: Users can insert payments for their business
CREATE POLICY "Users can create payments for their business" ON payments
    FOR INSERT WITH CHECK (
        business_id IN (
            SELECT business_id FROM user_profiles WHERE id = auth.uid()
        )
    );

-- RLS Policy: Users can update payments for their business
CREATE POLICY "Users can update their business payments" ON payments
    FOR UPDATE USING (
        business_id IN (
            SELECT business_id FROM user_profiles WHERE id = auth.uid()
        )
    );

-- RLS Policy: Users can delete payments for their business
CREATE POLICY "Users can delete their business payments" ON payments
    FOR DELETE USING (
        business_id IN (
            SELECT business_id FROM user_profiles WHERE id = auth.uid()
        )
    );

-- RLS Policy: Service role can manage all payments
CREATE POLICY "Service role can manage all payments" ON payments
    FOR ALL USING (auth.role() = 'service_role');

-- Create trigger for updated_at timestamp
CREATE OR REPLACE FUNCTION update_payments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER payments_updated_at_trigger
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_payments_updated_at();

-- Add comments for documentation
COMMENT ON TABLE payments IS 'Stores all payment records against invoices with complete payment history';
COMMENT ON COLUMN payments.amount IS 'Payment amount in business currency';
COMMENT ON COLUMN payments.payment_mode IS 'Method of payment (cash, UPI, bank transfer, etc.)';
COMMENT ON COLUMN payments.payment_date IS 'Date and time when payment was received';
COMMENT ON COLUMN payments.reference IS 'Payment reference number (transaction ID, cheque number, etc.)';
COMMENT ON COLUMN payments.receipt_url IS 'URL to payment receipt document if available';
COMMENT ON COLUMN payments.notes IS 'Additional notes or comments about the payment';
