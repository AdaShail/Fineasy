-- Migration: Create Recurring Payments Tables
-- Description: Add support for recurring payments with automatic invoice generation
-- Date: 2025-11-13

-- ============================================
-- 1. Create recurring_payments table
-- ============================================

CREATE TABLE IF NOT EXISTS recurring_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE CASCADE,
    
    -- Recurring configuration
    description TEXT NOT NULL,
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
    day_of_month INTEGER CHECK (day_of_month BETWEEN 1 AND 31),
    day_of_week INTEGER CHECK (day_of_week BETWEEN 1 AND 7),
    
    -- Date range
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    max_occurrences INTEGER CHECK (max_occurrences > 0),
    
    -- Status and tracking
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'cancelled', 'completed')),
    last_generated_date TIMESTAMP,
    occurrences_generated INTEGER NOT NULL DEFAULT 0,
    
    -- Invoice/Transaction settings
    auto_generate_invoice BOOLEAN NOT NULL DEFAULT true,
    auto_send_reminder BOOLEAN NOT NULL DEFAULT false,
    reminder_days_before INTEGER NOT NULL DEFAULT 3,
    
    -- Metadata
    notes TEXT,
    metadata JSONB,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT recurring_payment_customer_or_supplier CHECK (
        (customer_id IS NOT NULL AND supplier_id IS NULL) OR
        (customer_id IS NULL AND supplier_id IS NOT NULL)
    ),
    CONSTRAINT recurring_payment_monthly_day CHECK (
        (frequency = 'monthly' AND day_of_month IS NOT NULL) OR
        (frequency != 'monthly')
    ),
    CONSTRAINT recurring_payment_weekly_day CHECK (
        (frequency = 'weekly' AND day_of_week IS NOT NULL) OR
        (frequency != 'weekly')
    )
);

-- Create indexes
CREATE INDEX idx_recurring_payments_business ON recurring_payments(business_id);
CREATE INDEX idx_recurring_payments_customer ON recurring_payments(customer_id);
CREATE INDEX idx_recurring_payments_supplier ON recurring_payments(supplier_id);
CREATE INDEX idx_recurring_payments_status ON recurring_payments(status);
CREATE INDEX idx_recurring_payments_next_gen ON recurring_payments(status, last_generated_date) 
    WHERE status = 'active';

-- Add RLS policies
ALTER TABLE recurring_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view recurring payments for their businesses"
    ON recurring_payments FOR SELECT
    USING (
        business_id IN (
            SELECT id FROM businesses WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create recurring payments for their businesses"
    ON recurring_payments FOR INSERT
    WITH CHECK (
        business_id IN (
            SELECT id FROM businesses WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update recurring payments for their businesses"
    ON recurring_payments FOR UPDATE
    USING (
        business_id IN (
            SELECT id FROM businesses WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete recurring payments for their businesses"
    ON recurring_payments FOR DELETE
    USING (
        business_id IN (
            SELECT id FROM businesses WHERE user_id = auth.uid()
        )
    );

-- ============================================
-- 2. Create recurring_payment_occurrences table
-- ============================================

CREATE TABLE IF NOT EXISTS recurring_payment_occurrences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recurring_payment_id UUID NOT NULL REFERENCES recurring_payments(id) ON DELETE CASCADE,
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE CASCADE,
    
    -- Links to generated entities
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL,
    
    -- Occurrence details
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    due_date TIMESTAMP NOT NULL,
    generated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Status tracking
    invoice_generated BOOLEAN NOT NULL DEFAULT false,
    reminder_sent BOOLEAN NOT NULL DEFAULT false,
    paid BOOLEAN NOT NULL DEFAULT false,
    paid_at TIMESTAMP,
    
    -- Metadata
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_recurring_occurrences_recurring_payment ON recurring_payment_occurrences(recurring_payment_id);
CREATE INDEX idx_recurring_occurrences_business ON recurring_payment_occurrences(business_id);
CREATE INDEX idx_recurring_occurrences_customer ON recurring_payment_occurrences(customer_id);
CREATE INDEX idx_recurring_occurrences_supplier ON recurring_payment_occurrences(supplier_id);
CREATE INDEX idx_recurring_occurrences_invoice ON recurring_payment_occurrences(invoice_id);
CREATE INDEX idx_recurring_occurrences_due_date ON recurring_payment_occurrences(due_date);
CREATE INDEX idx_recurring_occurrences_paid ON recurring_payment_occurrences(paid);
CREATE INDEX idx_recurring_occurrences_unpaid_due ON recurring_payment_occurrences(due_date) 
    WHERE paid = false;

-- Add RLS policies
ALTER TABLE recurring_payment_occurrences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view occurrences for their businesses"
    ON recurring_payment_occurrences FOR SELECT
    USING (
        business_id IN (
            SELECT id FROM businesses WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "System can create occurrences"
    ON recurring_payment_occurrences FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can update occurrences for their businesses"
    ON recurring_payment_occurrences FOR UPDATE
    USING (
        business_id IN (
            SELECT id FROM businesses WHERE user_id = auth.uid()
        )
    );

-- ============================================
-- 3. Create trigger for updated_at
-- ============================================

CREATE OR REPLACE FUNCTION update_recurring_payment_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_recurring_payments_updated_at
    BEFORE UPDATE ON recurring_payments
    FOR EACH ROW
    EXECUTE FUNCTION update_recurring_payment_updated_at();

CREATE TRIGGER trigger_recurring_occurrences_updated_at
    BEFORE UPDATE ON recurring_payment_occurrences
    FOR EACH ROW
    EXECUTE FUNCTION update_recurring_payment_updated_at();

-- ============================================
-- 4. Create function to process recurring payments
-- ============================================

CREATE OR REPLACE FUNCTION process_recurring_payments(p_business_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER := 0;
    v_recurring RECORD;
    v_next_date TIMESTAMP;
    v_occurrence_id UUID;
BEGIN
    -- Loop through active recurring payments
    FOR v_recurring IN
        SELECT * FROM recurring_payments
        WHERE business_id = p_business_id
        AND status = 'active'
        AND (end_date IS NULL OR end_date >= NOW())
        AND (max_occurrences IS NULL OR occurrences_generated < max_occurrences)
    LOOP
        -- Calculate next occurrence date
        IF v_recurring.last_generated_date IS NULL THEN
            v_next_date := v_recurring.start_date;
        ELSE
            -- Calculate based on frequency
            CASE v_recurring.frequency
                WHEN 'daily' THEN
                    v_next_date := v_recurring.last_generated_date + INTERVAL '1 day';
                WHEN 'weekly' THEN
                    v_next_date := v_recurring.last_generated_date + INTERVAL '1 week';
                WHEN 'monthly' THEN
                    v_next_date := v_recurring.last_generated_date + INTERVAL '1 month';
                WHEN 'yearly' THEN
                    v_next_date := v_recurring.last_generated_date + INTERVAL '1 year';
            END CASE;
        END IF;
        
        -- Check if it's time to generate
        IF v_next_date <= NOW() THEN
            -- Create occurrence
            INSERT INTO recurring_payment_occurrences (
                recurring_payment_id,
                business_id,
                customer_id,
                supplier_id,
                amount,
                due_date,
                generated_at
            ) VALUES (
                v_recurring.id,
                v_recurring.business_id,
                v_recurring.customer_id,
                v_recurring.supplier_id,
                v_recurring.amount,
                v_next_date,
                NOW()
            ) RETURNING id INTO v_occurrence_id;
            
            -- Update recurring payment
            UPDATE recurring_payments
            SET last_generated_date = v_next_date,
                occurrences_generated = occurrences_generated + 1,
                updated_at = NOW()
            WHERE id = v_recurring.id;
            
            -- Check if completed
            IF v_recurring.max_occurrences IS NOT NULL 
               AND v_recurring.occurrences_generated + 1 >= v_recurring.max_occurrences THEN
                UPDATE recurring_payments
                SET status = 'completed',
                    updated_at = NOW()
                WHERE id = v_recurring.id;
            END IF;
            
            v_count := v_count + 1;
        END IF;
    END LOOP;
    
    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. Add comments
-- ============================================

COMMENT ON TABLE recurring_payments IS 'Stores recurring payment configurations for automatic invoice generation';
COMMENT ON TABLE recurring_payment_occurrences IS 'Stores individual occurrences generated from recurring payments';
COMMENT ON FUNCTION process_recurring_payments IS 'Processes all active recurring payments and generates occurrences';

-- ============================================
-- 6. Grant permissions
-- ============================================

GRANT SELECT, INSERT, UPDATE, DELETE ON recurring_payments TO authenticated;
GRANT SELECT, INSERT, UPDATE ON recurring_payment_occurrences TO authenticated;
GRANT EXECUTE ON FUNCTION process_recurring_payments TO authenticated;
