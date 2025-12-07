
SELECT 
    'invoices.transaction_id' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'invoices' AND column_name = 'transaction_id'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

SELECT 
    'invoices.pdf_path' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'invoices' AND column_name = 'pdf_path'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

SELECT 
    'invoices.pdf_generated_at' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'invoices' AND column_name = 'pdf_generated_at'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

-- Check transactions table modifications
SELECT 
    'transactions.invoice_id' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'transactions' AND column_name = 'invoice_id'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

-- Check payments table exists
SELECT 
    'payments table' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'payments'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

-- Check payments table columns
SELECT 
    'payments columns' as check_name,
    CASE 
        WHEN (
            SELECT COUNT(*) FROM information_schema.columns 
            WHERE table_name = 'payments' 
            AND column_name IN (
                'id', 'business_id', 'user_id', 'invoice_id', 
                'transaction_id', 'customer_id', 'amount', 
                'payment_mode', 'payment_date', 'reference', 
                'notes', 'receipt_url', 'created_at', 'updated_at'
            )
        ) >= 14 THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

-- Check indexes
SELECT 
    'idx_invoices_transaction_id' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_indexes 
            WHERE indexname = 'idx_invoices_transaction_id'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

SELECT 
    'idx_transactions_invoice_id' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_indexes 
            WHERE indexname = 'idx_transactions_invoice_id'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

SELECT 
    'idx_payments_invoice_id' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_indexes 
            WHERE indexname = 'idx_payments_invoice_id'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

SELECT 
    'idx_payments_customer_id' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_indexes 
            WHERE indexname = 'idx_payments_customer_id'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

SELECT 
    'idx_payments_business_id' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_indexes 
            WHERE indexname = 'idx_payments_business_id'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

-- Check trigger function exists
SELECT 
    'update_invoice_status function' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_proc 
            WHERE proname = 'update_invoice_status'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

SELECT 
    'mark_overdue_invoices function' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_proc 
            WHERE proname = 'mark_overdue_invoices'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

-- Check trigger exists
SELECT 
    'invoice_status_update_trigger' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers 
            WHERE trigger_name = 'invoice_status_update_trigger'
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

-- Check RLS is enabled on payments
SELECT 
    'payments RLS enabled' as check_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_tables 
            WHERE tablename = 'payments' AND rowsecurity = true
        ) THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status;

-- Summary
SELECT 
    '=== MIGRATION VERIFICATION SUMMARY ===' as summary,
    '' as status
UNION ALL
SELECT 
    'Total Checks' as summary,
    COUNT(*)::text as status
FROM (
    SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'transaction_id'
    UNION ALL SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'pdf_path'
    UNION ALL SELECT 1 FROM information_schema.columns WHERE table_name = 'invoices' AND column_name = 'pdf_generated_at'
    UNION ALL SELECT 1 FROM information_schema.columns WHERE table_name = 'transactions' AND column_name = 'invoice_id'
    UNION ALL SELECT 1 FROM information_schema.tables WHERE table_name = 'payments'
    UNION ALL SELECT 1 FROM pg_indexes WHERE indexname = 'idx_invoices_transaction_id'
    UNION ALL SELECT 1 FROM pg_indexes WHERE indexname = 'idx_transactions_invoice_id'
    UNION ALL SELECT 1 FROM pg_indexes WHERE indexname = 'idx_payments_invoice_id'
    UNION ALL SELECT 1 FROM pg_indexes WHERE indexname = 'idx_payments_customer_id'
    UNION ALL SELECT 1 FROM pg_indexes WHERE indexname = 'idx_payments_business_id'
    UNION ALL SELECT 1 FROM pg_proc WHERE proname = 'update_invoice_status'
    UNION ALL SELECT 1 FROM pg_proc WHERE proname = 'mark_overdue_invoices'
    UNION ALL SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'invoice_status_update_trigger'
    UNION ALL SELECT 1 FROM pg_tables WHERE tablename = 'payments' AND rowsecurity = true
) checks;
