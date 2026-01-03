import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Print orientation options
enum PrintOrientation {
  portrait,
  landscape,
}

/// Print page size options
enum PrintPageSize {
  a4,
  letter,
  legal,
}

/// Service for desktop-optimized printing
class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  /// Print a widget with custom styling
  Future<void> printWidget({
    required Widget widget,
    required BuildContext context,
    PrintOrientation orientation = PrintOrientation.portrait,
    PrintPageSize pageSize = PrintPageSize.a4,
    String? title,
  }) async {
    try {
      // Get the rendered widget as HTML
      final htmlContent = await _widgetToHtml(widget, context);

      // Use printHtml to handle the actual printing
      await printHtml(
        htmlContent: htmlContent,
        orientation: orientation,
        pageSize: pageSize,
        title: title,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Print HTML content directly
  Future<void> printHtml({
    required String htmlContent,
    PrintOrientation orientation = PrintOrientation.portrait,
    PrintPageSize pageSize = PrintPageSize.a4,
    String? title,
  }) async {
    try {
      // Create HTML document content
      final fullHtml = '''
        <!DOCTYPE html>
        <html>
        <head>
          <title>${title ?? 'Print'}</title>
          <style>
            @media print {
              @page {
                size: ${_getPageSize(pageSize)} ${orientation.name};
                margin: 1cm;
              }
              body {
                margin: 0;
                padding: 0;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              }
              .no-print {
                display: none !important;
              }
            }
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              padding: 20px;
            }
            table {
              width: 100%;
              border-collapse: collapse;
              margin: 20px 0;
            }
            th, td {
              border: 1px solid #ddd;
              padding: 12px;
              text-align: left;
            }
            th {
              background-color: #f5f5f5;
              font-weight: bold;
            }
            .header {
              margin-bottom: 30px;
              border-bottom: 2px solid #333;
              padding-bottom: 20px;
            }
            .footer {
              margin-top: 30px;
              border-top: 1px solid #ddd;
              padding-top: 20px;
              text-align: center;
              font-size: 12px;
              color: #666;
            }
          </style>
        </head>
        <body>
          $htmlContent
          <div class="footer no-print">
            <button onclick="window.print()">Print</button>
            <button onclick="window.close()">Close</button>
          </div>
        </body>
        </html>
      ''';

      // Create a blob and open in new window
      final blob = html.Blob([fullHtml], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, 'Print');
      
      // Clean up the URL after a delay
      Future.delayed(const Duration(seconds: 1), () {
        html.Url.revokeObjectUrl(url);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Print a table with data
  Future<void> printTable({
    required List<String> headers,
    required List<List<String>> rows,
    String? title,
    String? subtitle,
    PrintOrientation orientation = PrintOrientation.portrait,
    PrintPageSize pageSize = PrintPageSize.a4,
  }) async {
    final htmlContent = _generateTableHtml(
      headers: headers,
      rows: rows,
      title: title,
      subtitle: subtitle,
    );

    await printHtml(
      htmlContent: htmlContent,
      orientation: orientation,
      pageSize: pageSize,
      title: title,
    );
  }

  String _generateTableHtml({
    required List<String> headers,
    required List<List<String>> rows,
    String? title,
    String? subtitle,
  }) {
    final buffer = StringBuffer();

    if (title != null) {
      buffer.writeln('<div class="header">');
      buffer.writeln('<h1>$title</h1>');
      if (subtitle != null) {
        buffer.writeln('<p>$subtitle</p>');
      }
      buffer.writeln('</div>');
    }

    buffer.writeln('<table>');
    buffer.writeln('<thead><tr>');
    for (var header in headers) {
      buffer.writeln('<th>$header</th>');
    }
    buffer.writeln('</tr></thead>');

    buffer.writeln('<tbody>');
    for (var row in rows) {
      buffer.writeln('<tr>');
      for (var cell in row) {
        buffer.writeln('<td>$cell</td>');
      }
      buffer.writeln('</tr>');
    }
    buffer.writeln('</tbody>');
    buffer.writeln('</table>');

    buffer.writeln('<div class="footer">');
    buffer.writeln('<p>Generated on ${DateTime.now().toString()}</p>');
    buffer.writeln('</div>');

    return buffer.toString();
  }

  Future<String> _widgetToHtml(Widget widget, BuildContext context) async {
    // This is a simplified version - in production, you'd want to use
    // a more sophisticated widget-to-HTML conversion
    return '<div>Widget content would be rendered here</div>';
  }

  String _getPageSize(PrintPageSize size) {
    switch (size) {
      case PrintPageSize.a4:
        return 'A4';
      case PrintPageSize.letter:
        return 'letter';
      case PrintPageSize.legal:
        return 'legal';
    }
  }
}

/// Widget wrapper for printable content
class PrintableWidget extends StatelessWidget {
  final Widget child;
  final String? title;
  final PrintOrientation orientation;
  final PrintPageSize pageSize;

  const PrintableWidget({
    super.key,
    required this.child,
    this.title,
    this.orientation = PrintOrientation.portrait,
    this.pageSize = PrintPageSize.a4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Print button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () => _handlePrint(context),
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ),
        // Content
        Expanded(child: child),
      ],
    );
  }

  Future<void> _handlePrint(BuildContext context) async {
    await PrintService().printWidget(
      widget: child,
      context: context,
      orientation: orientation,
      pageSize: pageSize,
      title: title,
    );
  }
}

/// Print preview dialog
class PrintPreviewDialog extends StatelessWidget {
  final Widget content;
  final String? title;
  final PrintOrientation orientation;
  final PrintPageSize pageSize;

  const PrintPreviewDialog({
    super.key,
    required this.content,
    this.title,
    this.orientation = PrintOrientation.portrait,
    this.pageSize = PrintPageSize.a4,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.print),
                const SizedBox(width: 8),
                Text(
                  'Print Preview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),

            // Preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: content,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await PrintService().printWidget(
                      widget: content,
                      context: context,
                      orientation: orientation,
                      pageSize: pageSize,
                      title: title,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required Widget content,
    String? title,
    PrintOrientation orientation = PrintOrientation.portrait,
    PrintPageSize pageSize = PrintPageSize.a4,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PrintPreviewDialog(
        content: content,
        title: title,
        orientation: orientation,
        pageSize: pageSize,
      ),
    );
  }
}
