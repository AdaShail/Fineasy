import 'package:flutter/material.dart';
import 'package:fineasy/web/widgets/web_components.dart';
import 'package:intl/intl.dart';

/// Example screen demonstrating web UI components
class WebComponentsExampleScreen extends StatefulWidget {
  const WebComponentsExampleScreen({Key? key}) : super(key: key);

  @override
  State<WebComponentsExampleScreen> createState() => _WebComponentsExampleScreenState();
}

class _WebComponentsExampleScreenState extends State<WebComponentsExampleScreen> {
  // Sample data for examples
  final List<_SampleInvoice> _invoices = List.generate(
    50,
    (index) => _SampleInvoice(
      id: 'INV-${1000 + index}',
      customer: 'Customer ${index + 1}',
      amount: (1000 + index * 100).toDouble(),
      date: DateTime.now().subtract(Duration(days: index)),
      status: ['Paid', 'Pending', 'Overdue'][index % 3],
    ),
  );

  List<_SampleInvoice> _selectedInvoices = [];
  String? _selectedStatus;
  List<String> _selectedCategories = [];
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Components Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WebCard Examples
            _buildSection(
              'WebCard Examples',
              Column(
                children: [
                  WebCard(
                    title: const Text('Simple Card'),
                    subtitle: const Text('Basic card with title and subtitle'),
                    content: const Text('This is the card content area.'),
                    actions: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Action'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  WebCard(
                    title: const Text('Card with Status'),
                    leading: const Icon(Icons.analytics, size: 40),
                    statusIndicator: const WebCardStatusIndicator(
                      label: 'Active',
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Revenue: ₹1,50,000'),
                        SizedBox(height: 8),
                        Text('Pending: ₹25,000'),
                      ],
                    ),
                    expandable: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // WebFormField Examples
            _buildSection(
              'WebFormField Examples',
              Column(
                children: [
                  WebFormField(
                    label: 'Email Address',
                    hint: 'Enter your email',
                    helperText: 'We\'ll never share your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: WebFormValidators.combine([
                      WebFormValidators.required,
                      WebFormValidators.email,
                    ]),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 16),
                  WebFormField(
                    label: 'Password',
                    hint: 'Enter password',
                    obscureText: true,
                    validator: WebFormValidators.combine([
                      WebFormValidators.required,
                      WebFormValidators.minLength(8),
                    ]),
                    maxLength: 20,
                    showCharacterCount: true,
                  ),
                  const SizedBox(height: 16),
                  WebFormField(
                    label: 'Amount',
                    hint: 'Enter amount',
                    keyboardType: TextInputType.number,
                    validator: WebFormValidators.combine([
                      WebFormValidators.required,
                      WebFormValidators.numeric,
                      WebFormValidators.min(0),
                    ]),
                    prefixIcon: const Icon(Icons.currency_rupee),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // WebDatePicker Example
            _buildSection(
              'WebDatePicker Example',
              WebDatePicker(
                label: 'Invoice Date',
                hint: 'Select date',
                initialDate: _selectedDate,
                dateFormat: DateFormat('dd MMM yyyy'),
                showQuickSelects: true,
                required: true,
                onChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),

            const SizedBox(height: 32),

            // WebDropdown Examples
            _buildSection(
              'WebDropdown Examples',
              Column(
                children: [
                  WebDropdown<String>(
                    label: 'Payment Status',
                    hint: 'Select status',
                    options: const [
                      WebDropdownOption(
                        value: 'paid',
                        label: 'Paid',
                        leading: Icon(Icons.check_circle, color: Colors.green),
                      ),
                      WebDropdownOption(
                        value: 'pending',
                        label: 'Pending',
                        leading: Icon(Icons.pending, color: Colors.orange),
                      ),
                      WebDropdownOption(
                        value: 'overdue',
                        label: 'Overdue',
                        leading: Icon(Icons.error, color: Colors.red),
                      ),
                    ],
                    value: _selectedStatus,
                    onChanged: (value) {
                      setState(() => _selectedStatus = value);
                    },
                    searchable: true,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  WebDropdown<String>(
                    label: 'Categories',
                    hint: 'Select categories',
                    options: const [
                      WebDropdownOption(
                        value: 'sales',
                        label: 'Sales',
                        subtitle: 'Sales related transactions',
                      ),
                      WebDropdownOption(
                        value: 'expenses',
                        label: 'Expenses',
                        subtitle: 'Business expenses',
                      ),
                      WebDropdownOption(
                        value: 'inventory',
                        label: 'Inventory',
                        subtitle: 'Stock management',
                      ),
                    ],
                    values: _selectedCategories,
                    onMultiChanged: (values) {
                      setState(() => _selectedCategories = values);
                    },
                    multiSelect: true,
                    searchable: true,
                    searchHint: 'Search categories...',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // WebDataTable Example
            _buildSection(
              'WebDataTable Example',
              SizedBox(
                height: 600,
                child: WebDataTable<_SampleInvoice>(
                  data: _invoices,
                  columns: [
                    WebDataColumn(
                      label: 'Invoice #',
                      field: 'id',
                      valueGetter: (invoice) => invoice.id,
                    ),
                    WebDataColumn(
                      label: 'Customer',
                      field: 'customer',
                      valueGetter: (invoice) => invoice.customer,
                    ),
                    WebDataColumn(
                      label: 'Amount',
                      field: 'amount',
                      valueGetter: (invoice) => invoice.amount.toString(),
                      cellBuilder: (invoice) => Text(
                        '₹${invoice.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    WebDataColumn(
                      label: 'Date',
                      field: 'date',
                      valueGetter: (invoice) => DateFormat('dd MMM yyyy').format(invoice.date),
                    ),
                    WebDataColumn(
                      label: 'Status',
                      field: 'status',
                      valueGetter: (invoice) => invoice.status,
                      cellBuilder: (invoice) => _buildStatusChip(invoice.status),
                    ),
                  ],
                  onRowTap: (invoice) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped: ${invoice.id}')),
                    );
                  },
                  selectable: true,
                  onSelectionChanged: (selected) {
                    setState(() => _selectedInvoices = selected);
                  },
                  searchHint: 'Search invoices...',
                  rowsPerPage: 10,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export clicked')),
                        );
                      },
                      tooltip: 'Export',
                    ),
                  ],
                ),
              ),
            ),

            if (_selectedInvoices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Selected ${_selectedInvoices.length} invoice(s)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Paid':
        color = Colors.green;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      case 'Overdue':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Sample data model
class _SampleInvoice {
  final String id;
  final String customer;
  final double amount;
  final DateTime date;
  final String status;

  _SampleInvoice({
    required this.id,
    required this.customer,
    required this.amount,
    required this.date,
    required this.status,
  });
}
