import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AIService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Process natural language input to generate invoice data
  Future<Map<String, dynamic>?> processInvoiceNLP(String nlpInput) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/nlp/process-invoice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': nlpInput,
          'business_id':
              'current_business_id', // Replace with actual business ID
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return _convertNLPToInvoiceData(data['invoice_data']);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Extract text from image using OCR
  Future<Map<String, dynamic>?> extractTextFromImage(File imageFile) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/ocr/extract-text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image, 'format': 'base64'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Parse invoice from extracted text
  Future<Map<String, dynamic>?> parseInvoiceFromText(
    String extractedText,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/nlp/parse-invoice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': extractedText,
          'business_id':
              'current_business_id', // Replace with actual business ID
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Convert NLP response to invoice data format
  Map<String, dynamic> _convertNLPToInvoiceData(Map<String, dynamic> nlpData) {
    final now = DateTime.now();

    return {
      'id': 'temp_${now.millisecondsSinceEpoch}',
      'invoice_number':
          nlpData['invoice_number'] ?? 'INV-${now.millisecondsSinceEpoch}',
      'customer_name': nlpData['customer_name'] ?? 'Unknown Customer',
      'customer_email': nlpData['customer_email'] ?? '',
      'customer_phone': nlpData['customer_phone'] ?? '',
      'date': nlpData['date'] ?? now.toIso8601String(),
      'due_date':
          nlpData['due_date'] ??
          now.add(const Duration(days: 30)).toIso8601String(),
      'status': 'draft',
      'items':
          (nlpData['items'] as List<dynamic>?)
              ?.map(
                (item) => {
                  'id': 'item_${DateTime.now().millisecondsSinceEpoch}',
                  'description': item['description'] ?? 'Item',
                  'quantity': (item['quantity'] ?? 1).toDouble(),
                  'unit_price': (item['unit_price'] ?? 0.0).toDouble(),
                  'total_price':
                      ((item['quantity'] ?? 1) * (item['unit_price'] ?? 0.0))
                          .toDouble(),
                },
              )
              .toList() ??
          [],
      'subtotal': (nlpData['subtotal'] ?? 0.0).toDouble(),
      'tax_rate': (nlpData['tax_rate'] ?? 0.0).toDouble(),
      'tax_amount': (nlpData['tax_amount'] ?? 0.0).toDouble(),
      'discount_amount': (nlpData['discount_amount'] ?? 0.0).toDouble(),
      'total_amount': (nlpData['total_amount'] ?? 0.0).toDouble(),
      'notes': nlpData['notes'] ?? '',
    };
  }

  // Get business insights
  Future<Map<String, dynamic>?> getBusinessInsights(String businessId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/insights/business/$businessId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Generate financial predictions
  Future<Map<String, dynamic>?> getFinancialPredictions(
    String businessId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/predictions/financial/$businessId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Analyze transaction patterns
  Future<Map<String, dynamic>?> analyzeTransactionPatterns(
    String businessId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/analysis/transaction-patterns/$businessId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Detect fraud alerts
  Future<List<Map<String, dynamic>>> getFraudAlerts(String businessId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/fraud/alerts/$businessId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['alerts'] ?? []);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // Process document with OCR/NLP
  Future<Map<String, dynamic>?> processDocument(
    String filePath,
    String documentType,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/nlp/process-document'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['document_type'] = documentType;
      request.fields['business_id'] =
          'current_business_id'; // Replace with actual business ID

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return jsonDecode(responseData);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Get AI recommendations
  Future<List<Map<String, dynamic>>> getRecommendations(
    String businessId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recommendations/$businessId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['recommendations'] ?? []);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // Chat with AI assistant
  Future<String?> chatWithAI(String message, String businessId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message, 'business_id': businessId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
