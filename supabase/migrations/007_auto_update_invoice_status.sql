-- Migration: Auto-update invoice status based on due date and payments
-- This trigger automatically updates invoice status to 'overdue' when due date passes

-- Function to update overdue invoices
CREATE OR REPLACE FUNCTION update_overdue_invoices()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update invoices that are past due date and not paid
  UPDATE invoices
  SET 
    status = 'overdue',
    updated_at = NOW()
  WHERE 
    due_date < CURRENT_DATE
    AND status IN ('sent', 'partially_paid')
    AND status != 'paid'
    AND status != 'cancelled'
    AND status != 'draft';
    
  -- Log the update
  RAISE NOTICE 'Updated overdue invoices at %', NOW();
END;
$$;

-- Function to check and update invoice status on payment
CREATE OR REPLACE FUNCTION check_invoice_status_on_payment()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_invoice RECORD;
  v_new_status TEXT;
BEGIN
  -- Get invoice details
  SELECT 
    id,
    total_amount,
    paid_amount,
    due_date,
    status
  INTO v_invoice
  FROM invoices
  WHERE id = NEW.invoice_id;

  -- Calculate new status based on payment
  IF v_invoice.paid_amount >= v_invoice.total_amount THEN
    v_new_status := 'paid';
  ELSIF v_invoice.paid_amount > 0 THEN
    v_new_status := 'partially_paid';
  ELSIF v_invoice.due_date < CURRENT_DATE THEN
    v_new_status := 'overdue';
  ELSE
    v_new_status := 'sent';
  END IF;

  -- Update invoice status if changed
  IF v_invoice.status != v_new_status THEN
    UPDATE invoices
    SET 
      status = v_new_status,
      updated_at = NOW()
    WHERE id = v_invoice.id;
    
    RAISE NOTICE 'Invoice % status updated from % to %', v_invoice.id, v_invoice.status, v_new_status;
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger on payments table
DROP TRIGGER IF EXISTS trigger_check_invoice_status_on_payment ON payments;
CREATE TRIGGER trigger_check_invoice_status_on_payment
  AFTER INSERT OR UPDATE ON payments
  FOR EACH ROW
  WHEN (NEW.invoice_id IS NOT NULL)
  EXECUTE FUNCTION check_invoice_status_on_payment();

-- Function to update invoice status when invoice is modified
CREATE OR REPLACE FUNCTION check_invoice_status_on_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_new_status TEXT;
BEGIN
  -- Determine correct status
  IF NEW.paid_amount >= NEW.total_amount THEN
    v_new_status := 'paid';
  ELSIF NEW.paid_amount > 0 THEN
    v_new_status := 'partially_paid';
  ELSIF NEW.due_date < CURRENT_DATE AND NEW.status NOT IN ('paid', 'cancelled', 'draft') THEN
    v_new_status := 'overdue';
  ELSE
    v_new_status := NEW.status; -- Keep current status
  END IF;

  -- Update status if needed
  IF NEW.status != v_new_status THEN
    NEW.status := v_new_status;
    NEW.updated_at := NOW();
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger on invoices table
DROP TRIGGER IF EXISTS trigger_check_invoice_status_on_update ON invoices;
CREATE TRIGGER trigger_check_invoice_status_on_update
  BEFORE UPDATE ON invoices
  FOR EACH ROW
  EXECUTE FUNCTION check_invoice_status_on_update();

-- Create a scheduled job to run daily (requires pg_cron extension)
-- Note: This requires pg_cron extension to be enabled
-- Run this manually or set up a cron job in your deployment

-- Example cron job (uncomment if pg_cron is available):
-- SELECT cron.schedule(
--   'update-overdue-invoices',
--   '0 0 * * *', -- Run daily at midnight
--   $$SELECT update_overdue_invoices()$$
-- );

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION update_overdue_invoices() TO authenticated;
GRANT EXECUTE ON FUNCTION check_invoice_status_on_payment() TO authenticated;
GRANT EXECUTE ON FUNCTION check_invoice_status_on_update() TO authenticated;

-- Add comment
COMMENT ON FUNCTION update_overdue_invoices() IS 'Updates invoice status to overdue for invoices past due date';
COMMENT ON FUNCTION check_invoice_status_on_payment() IS 'Automatically updates invoice status when payment is recorded';
COMMENT ON FUNCTION check_invoice_status_on_update() IS 'Validates and corrects invoice status on update';
