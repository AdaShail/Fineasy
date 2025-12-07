-- =============================================================================
-- Migration: Create Invoice Status Update Trigger
-- Version: 004
-- Description: Creates a database trigger to automatically update invoice status
--              based on paid_amount, handling partially_paid, paid, and overdue
--              status transitions
-- Requirements: 2.2, 2.3, 2.5
-- =============================================================================

-- Create or replace the trigger function for automatic invoice status updates
CREATE OR REPLACE FUNCTION update_invoice_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Auto-update status based on paid amount and due date
    
    -- If invoice is fully paid
    IF NEW.paid_amount >= NEW.total_amount THEN
        NEW.status = 'paid';
    
    -- If invoice is partially paid (some payment received but not full amount)
    ELSIF NEW.paid_amount > 0 AND NEW.paid_amount < NEW.total_amount THEN
        NEW.status = 'partially_paid';
    
    -- If invoice is overdue (past due date and not paid or cancelled)
    ELSIF NEW.due_date IS NOT NULL 
          AND NEW.due_date < NOW() 
          AND NEW.status NOT IN ('paid', 'cancelled', 'partially_paid') THEN
        NEW.status = 'overdue';
    
    -- If invoice was overdue but now has partial payment
    ELSIF NEW.status = 'overdue' 
          AND NEW.paid_amount > 0 
          AND NEW.paid_amount < NEW.total_amount THEN
        NEW.status = 'partially_paid';
    END IF;
    
    -- Always update the updated_at timestamp
    NEW.updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger on invoices table
DROP TRIGGER IF EXISTS invoice_status_update_trigger ON invoices;

CREATE TRIGGER invoice_status_update_trigger
    BEFORE UPDATE ON invoices
    FOR EACH ROW
    WHEN (
        -- Only trigger when paid_amount, total_amount, or due_date changes
        OLD.paid_amount IS DISTINCT FROM NEW.paid_amount OR
        OLD.total_amount IS DISTINCT FROM NEW.total_amount OR
        OLD.due_date IS DISTINCT FROM NEW.due_date
    )
    EXECUTE FUNCTION update_invoice_status();

-- Create a function to check and update overdue invoices (for scheduled jobs)
CREATE OR REPLACE FUNCTION mark_overdue_invoices()
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    -- Update all invoices that are past due date and not paid/cancelled
    UPDATE invoices
    SET status = 'overdue',
        updated_at = NOW()
    WHERE due_date < NOW()
      AND status NOT IN ('paid', 'cancelled', 'partially_paid')
      AND status != 'overdue';
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

-- Add comments for documentation
COMMENT ON FUNCTION update_invoice_status() IS 'Automatically updates invoice status based on paid_amount and due_date';
COMMENT ON FUNCTION mark_overdue_invoices() IS 'Batch function to mark all overdue invoices (can be called by scheduled job)';

-- Note: To run the overdue check periodically, you can set up a cron job or scheduled function
-- Example: SELECT cron.schedule('mark-overdue-invoices', '0 0 * * *', 'SELECT mark_overdue_invoices()');
