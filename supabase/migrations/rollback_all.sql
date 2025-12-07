
DROP TRIGGER IF EXISTS invoice_status_update_trigger ON invoices;
DROP TRIGGER IF EXISTS payments_updated_at_trigger ON payments;

DROP FUNCTION IF EXISTS update_invoice_status();
DROP FUNCTION IF EXISTS mark_overdue_invoices();
DROP FUNCTION IF EXISTS update_payments_updated_at();
DROP TABLE IF EXISTS payments CASCADE;

ALTER TABLE transactions DROP COLUMN IF EXISTS invoice_id;

ALTER TABLE invoices DROP COLUMN IF EXISTS transaction_id;
ALTER TABLE invoices DROP COLUMN IF EXISTS pdf_path;
ALTER TABLE invoices DROP COLUMN IF EXISTS pdf_generated_at;

SELECT 
    'Rollback Verification' as check_type,
    'All migrations rolled back successfully' as message
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'invoices' AND column_name IN ('transaction_id', 'pdf_path', 'pdf_generated_at')
)
AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'transactions' AND column_name = 'invoice_id'
)
AND NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_name = 'payments'
)
AND NOT EXISTS (
    SELECT 1 FROM pg_proc 
    WHERE proname IN ('update_invoice_status', 'mark_overdue_invoices', 'update_payments_updated_at')
);


