# AI Client Service Documentation

## Overview

The AI Client Service provides a Flutter interface to communicate with the Python AI backend for business intelligence features including fraud detection, predictive analytics, compliance checking, and natural language invoice generation.

## Features

- **Fraud Detection**: Analyze transactions for duplicates, payment mismatches, and suspicious patterns
- **Predictive Analytics**: Get business insights and cash flow predictions
- **Compliance Checking**: Validate invoices against GST and tax regulations
- **NLP Invoice Generation**: Create invoices from natural language input
- **Offline Support**: Cached responses available when offline
- **Error Handling**: Comprehensive error handling with retry logic
- **Authentication**: Automatic Supabase token management

## Quick Start

### 1. Initialize the Service

```dart
import 'package:your_app/services/ai_client_service.dart';

final aiService = AIClientService();
await aiService.initialize();
```

### 2. Check Service Availability

```dart
bool isAvailable = await aiService.isServiceAvailable();
if (!isAvailable) {
  // Handle offline or service unavailable scenario
  return;
}
```

### 3. Analyze Fraud

```dart
try {
  final fraudAnalysis = await aiService.analyzeFraud('business-id');
  
  if (fraudAnalysis.alerts.isNotEmpty) {
    // Display fraud alerts to user
    for (final alert in fraudAnalysis.alerts) {
      print('Alert: ${alert.message}');
      print('Confidence: ${alert.confidenceScore}');
    }
  }
} on AIOfflineException {
  // Handle offline scenario
} on AIServiceException catch (e) {
  // Handle other AI service errors
  print('Error: ${e.message}');
}
```

### 4. Get Business Insights

```dart
try {
  final insights = await aiService.getPredictiveInsights('business-id');
  
  for (final insight in insights.insights) {
    print('Insight: ${insight.title}');
    print('Description: ${insight.description}');
    print('Recommendations: ${insight.recommendations.join(', ')}');
  }
} on AIInsufficientDataException {
  // Not enough data for insights
} on AIServiceException catch (e) {
  // Handle errors
}
```

### 5. Check Compliance

```dart
try {
  final compliance = await aiService.checkCompliance('invoice-id');
  
  if (compliance.issues.isNotEmpty) {
    for (final issue in compliance.issues) {
      print('Issue: ${issue.description}');
      print('Explanation: ${issue.plainLanguageExplanation}');
      print('Fixes: ${issue.suggestedFixes.join(', ')}');
    }
  }
} on AIServiceException catch (e) {
  // Handle errors
}
```

### 6. Generate Invoice from Text

```dart
try {
  final result = await aiService.generateInvoiceFromText(
    'Create invoice for John Doe, 5 items at 100 each with UPI payment',
    'business-id'
  );
  
  if (result.success) {
    print('Invoice created: ${result.invoiceId}');
    // Use result.invoiceData to populate invoice form
  } else {
    print('Errors: ${result.errors.join(', ')}');
    print('Suggestions: ${result.suggestions.join(', ')}');
  }
} on AIOfflineException {
  // Handle offline scenario
} on AIServiceException catch (e) {
  // Handle errors
}
```

## Error Handling

The service provides specific exception types for different error scenarios:

### Exception Types

- `AIOfflineException`: Device is offline or no internet connection
- `AINetworkException`: Network connectivity issues
- `AIAuthenticationException`: Authentication failed
- `AIServiceUnavailableException`: AI backend is temporarily unavailable
- `AIProcessingException`: Error processing the request
- `AIInsufficientDataException`: Not enough data for analysis
- `AITimeoutException`: Request timed out

### Error Handling Pattern

```dart
try {
  final result = await aiService.someMethod();
  // Handle success
} on AIOfflineException {
  // Show offline message, use cached data if available
} on AIInsufficientDataException {
  // Show message about needing more data
} on AIAuthenticationException {
  // Redirect to login
} on AIServiceUnavailableException {
  // Show service unavailable message
} on AIServiceException catch (e) {
  // Generic error handling
  showErrorDialog(e.message, e.recoveryAction);
} catch (e) {
  // Unexpected errors
  showErrorDialog('An unexpected error occurred');
}
```

## Caching

The service automatically caches responses to improve performance and provide offline functionality:

- **Fraud Analysis**: Cached for 30 minutes
- **Business Insights**: Cached for 6 hours  
- **Compliance Results**: Cached for 1 hour

### Cache Management

```dart
// Clear all cached data
await aiService.clearCache();

// Check if service is available (uses cache when offline)
bool available = await aiService.isServiceAvailable();
```

## Configuration

Configure the AI service through environment variables:

```env
# .env file
AI_BACKEND_URL=http://localhost:8000
ENABLE_FRAUD_ALERTS=true
ENABLE_PREDICTIVE_INSIGHTS=true
ENABLE_COMPLIANCE_CHECKING=true
ENABLE_NLP_INVOICE=true
```

## Integration Example

See `lib/services/ai_service_integration_example.dart` for complete examples of integrating AI features into Flutter widgets with proper error handling and user feedback.

## Models

### Request Models
- `InvoiceGenerationRequest`: For NLP invoice generation

### Response Models
- `FraudAnalysisResponse`: Contains fraud alerts and risk scores
- `BusinessInsightsResponse`: Contains business insights and recommendations
- `ComplianceResponse`: Contains compliance issues and status
- `InvoiceGenerationResponse`: Contains generated invoice data

### Data Models
- `FraudAlert`: Individual fraud detection alert
- `BusinessInsight`: Individual business insight with recommendations
- `ComplianceIssue`: Individual compliance issue with fixes
- `AIErrorResponse`: Error response from API

## Testing

The service includes comprehensive tests:

```bash
# Run AI model tests
flutter test test/models/ai_models_simple_test.dart

# Run all tests
flutter test
```

## Performance Considerations

- Responses are cached to reduce API calls
- Requests timeout after 30 seconds
- Automatic retry with exponential backoff for transient failures
- Background processing for non-critical operations

## Security

- All requests include authentication tokens
- Data is encrypted in transit
- Sensitive data is not logged in production
- Cached data is stored securely on device